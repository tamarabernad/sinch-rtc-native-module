//
//  SinchCallManager.swift
//  Blue Call
//
//  Created by Tamara Bernad on 2017-06-16.
//  Copyright © 2017 Blue Call. All rights reserved.
//

import Foundation
import UIKit

class SinchCallManager:NSObject{
    // Environment
    var isMessagingEnabled:Bool = false;
    var appKey:String = "";
    var appSecret:String = "";
    var host:String = "";
    
    var inCall:Bool = false;
    var isCallKit: Bool{
        guard let _callKitProvider = callKitProvider, let _sinchCall = sinchCall else {return false}
        return _callKitProvider.callExists(_sinchCall)
    }
    var callDelegate:CallDelegate?
    var messagesDelegate:MessagesDelegate?
    var notificationsHandler:NotificationsHandlerable?
    var messagesHandler:MessagesHandlerable?
    
    var sinchCall:SINCall?;
    var push:SINManagedPush;
    var client:SINClient?;
    var callKitProvider:SINCallKitProvider?;
    var remoteNotificationIncomingDisplayName:String?;
    var callerDisplayName:String{
        get{
            guard let _remote = remoteNotificationIncomingDisplayName else {
                return "Caller"
            }
            return _remote;
        }
    }
    
    required init(props: [String : Any]) {
        var environment = SINAPSEnvironment.production;
        if let _environment = props["environment"] as? String{
            environment = _environment == "dev" ? SINAPSEnvironment.development : SINAPSEnvironment.production;
        }
        
        push = Sinch.managedPush(with: environment)
        
        if let _isMessagingEnabled = props["isMessagingEnabled"] as? Bool{
            isMessagingEnabled = _isMessagingEnabled;
        }
        if let _appKey = props["appKey"] as? String, let _appSecret = props["appSecret"] as? String, let _host = props["host"] as? String{
            appKey = _appKey;
            appSecret = _appSecret;
            host = _host;
        }
        if let _notificationsHandler = props["notificationsHandler"] as? NotificationsHandlerable{
            notificationsHandler = _notificationsHandler;
        }
        
        if let _messagesHandler = props["messagesHandler"] as? MessagesHandlerable{
            messagesHandler = _messagesHandler;
        }
        super.init()
        
        self.push.delegate = self;
        self.push.setDesiredPushTypeAutomatically()
    }
    
    func initSinchClient(with userId:String){
        if(client == nil){
            UserDefaults.standard.set(userId, forKey: "userId");
            client = Sinch.client(withApplicationKey: appKey, applicationSecret: appSecret, environmentHost: host, userId: userId)
          
            client?.delegate = self
            client?.call().delegate = self
            if(self.isMessagingEnabled){
                client?.messageClient().delegate = self
                client?.setSupportMessaging(true)
            }
            client?.setSupportCalling(true)
            client?.enableManagedPushNotifications()
            client?.start()
            client?.startListeningOnActiveConnection()
            
            guard let _client = client else {return}
            callKitProvider = SINCallKitProvider(client: _client)
            
        }
    }   
    func disabledUserDefaultsStatusReceiveIncomingCalls()->Bool{
        return false;
    }
    func canReceiveIncomingCall()->Bool{
        return !self.disabledUserDefaultsStatusReceiveIncomingCalls() && !self.inCall;
    }
}

extension SinchCallManager:SINCallClientDelegate{
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        if(!self.canReceiveIncomingCall()){return;}
        self.sinchCall = call;
        self.sinchCall?.delegate = self
        
        self.callKitProvider?.reportNewIncomingCall(call, withDisplayName: self.callerDisplayName);
    }
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        if(!self.canReceiveIncomingCall()){return;}
        self.sinchCall = call;
        self.sinchCall?.delegate = self
        self.callKitProvider?.reportNewIncomingCall(call, withDisplayName: self.callerDisplayName);
    }
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        if #available(iOS 10.0, *) {
            return nil;
        }
        if(!self.canReceiveIncomingCall()) {return nil;}
        self.sinchCall = call;
        self.sinchCall?.delegate = self
        
        guard let not:UILocalNotification = self.notificationsHandler?.notificationForIncomingCall(withDisplayName: self.callerDisplayName) else{
            let notification:SINLocalNotification = SINLocalNotification();
            
            notification.alertAction = NSLocalizedString("SIN_INCOMING_CALL", tableName: nil, bundle: Bundle.main, value: "", comment: "")
            notification.alertBody = NSLocalizedString("SIN_INCOMING_CALL_DISPLAY_NAME", tableName: nil, bundle: Bundle.main, value: "", comment: "");
            return notification;
        }
        
        
        let notification:SINLocalNotification = SINLocalNotification();
        notification.alertAction = not.alertAction;
        notification.alertBody = not.alertBody;
        notification.soundName = not.soundName;
        return notification;
    }

}
extension SinchCallManager:SINClientDelegate{
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started successfully (version: \(Sinch.version()))")
    }
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch client error: \(error.localizedDescription)")
    }
}
extension SinchCallManager:SINManagedPushDelegate{
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        if client == nil{
            if let userId = UserDefaults.standard.object(forKey: "userId"){
                initSinchClient(with: userId as! String);
            }
        }
        
        if let _ = payload["sin"], let aps = payload["aps"] as? NSDictionary, let alert = aps["alert"] as? NSDictionary, let args = alert["loc-args"] as? NSArray, let name = args.firstObject as? String{
            self.remoteNotificationIncomingDisplayName = name
        }
        
        guard let result = self.client?.relayRemotePushNotification(payload) else{return}
        if(result.isCall()){
            guard let _ = result.call() else{return;}
        }else if(result.isMessage()){
        
            self.notificationsHandler?.handleMessageNotification(withPayload: payload, messageId: result.messageResult().messageId , senderId: result.messageResult().senderId)
        }
    }
}
extension SinchCallManager:CallManageable{
    func login(_ userId:String){
        self.initSinchClient(with: userId)
    }
    func logout(){
        self.client?.unregisterPushNotificationDeviceToken()
        self.client?.stopListeningOnActiveConnection()
        self.client = nil;
    }
    func setDisplayName(_ name:String){
        self.push.setDisplayName(name);
    }
    func call(with callParams: CallParams)->String? {
        
        guard let call = self.client?.call().callUser(withId: callParams.calleeId) else {return nil;}
        self.sinchCall = call;
        self.sinchCall?.delegate = self
        return call.callId;
    }
    func answer() {
        self.sinchCall?.answer()
    }
    func hangup() {
        self.sinchCall?.hangup()
    }
    func sendMessage(params:MessageParams)->MessageParams?{
        if(client == nil){
            //TODO: move to a method
            if let userId = UserDefaults.standard.object(forKey: "userId"){
                initSinchClient(with: userId as! String);
            }
        }
        guard let _receivers = params.receiverIds else {return nil};
        guard let _text = params.text else {return nil};
        
        let message = SINOutgoingMessage(recipients: _receivers, text: _text)
        
        if let _headers = params.headers {
            for header in _headers{
                message?.addHeader(withValue: header.value, key: header.key)
            }
        }
        
        guard let _client = self.client?.messageClient() else {return nil;}
        _client.send(message)
        
        let result = params.copy() as! MessageParams
        result.messageId = message?.messageId;
        
        if let _message = message{
            self.messagesHandler?.onSendingMessage(withMessageId: _message.messageId, headers: _message.headers, recipients: _message.recipientIds, text: _message.text, date: Date())
        }
        
        return result;
    }
    func terminate(){
        if(client != nil){
            client?.stopListeningOnActiveConnection()
            client?.terminate()
        }
    }
    func terminateGracefully(){
        if(client != nil){
            client?.stopListeningOnActiveConnection()
            client?.terminateGracefully()
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        self.push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken);
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any]){
        self.push.application(application, didReceiveRemoteNotification: userInfo)
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        self.push.application(application, didReceiveRemoteNotification: userInfo)
    }
}
extension SinchCallManager:SINCallDelegate{
    func callDidProgress(_ call: SINCall!) {
        self.callDelegate?.callDidProgress()
    }
    func callDidEnd(_ call: SINCall!) {
        inCall = false;
        var result:String = "";
        if let _ = call.details.error as NSError?{
            result = ""
        }else{
            let cause = call.details.endCause;
            switch cause {
            case .canceled:
                result = "CANCELED"
                break;
            case .noAnswer:
                result = "NO_ANSWER"
                break;
            case .denied:
                result = "DENIED"
                break;
            case .timeout:
                result = "TIMEOUT"
                break;
            case .hungUp:
                result = "HUNG_UP"
                break;
            case .otherDeviceAnswered:
                result = "OTHER_DEVICE_ANSWERED"
                break;
            case .none:
                result = "NONE"
                break;
            default:
                result = ""
            }
        }
        
        var duration = 0.0;
        if let begin = sinchCall?.details.establishedTime,let end = sinchCall?.details.endedTime {
            duration = end.timeIntervalSince(begin);
        }
        self.callDelegate?.callDidEnd(reason: result, duration: duration)
        self.callKitProvider?.reportCallEnded(call)
        self.remoteNotificationIncomingDisplayName = nil;
    }
    func callDidEstablish(_ call: SINCall!) {
        inCall = true;
        self.callDelegate?.callDidEstablish()
    }
}
extension SinchCallManager:SINMessageClientDelegate{

    func messageClient(_ messageClient:SINMessageClient!, didReceiveIncomingMessage message: SINMessage!) {
        self.messagesHandler?.onIncomingMessage(withMessageId: message.messageId, headers: message.headers, senderId: message.senderId, recipients: message.recipientIds, text: message.text, date: message.timestamp);
        self.messagesDelegate?.didReceiveMessage(messageId: message.messageId, headers: message.headers, senderId: message.senderId, recipients: message.recipientIds, text: message.text, date: message.timestamp);
    }
    func messageSent(_ message: SINMessage!, recipientId: String!) {
        self.messagesDelegate?.messageWasSent(messageId: message.messageId, headers: message.headers, recipients: message.recipientIds, text: message.text, date: message.timestamp)
    }
    func message(_ message: SINMessage!, shouldSendPushNotifications pushPairs: [Any]!) {
        
    }
    func messageDelivered(_ info: SINMessageDeliveryInfo!) {
        self.messagesDelegate?.messageWasDelivered(messageId: info.messageId, recipient: info.recipientId, date: info.timestamp)
    }
    public func messageFailed(_ message: SINMessage!, info messageFailureInfo: SINMessageFailureInfo!) {
        self.messagesDelegate?.messageFaildToDeliver(messageId: message.messageId, headers: message.headers
            , recipients: message.recipientIds, text: message.text, date: message.timestamp, error: messageFailureInfo.error)
    }
}
