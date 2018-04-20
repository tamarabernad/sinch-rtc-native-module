//
//  SinchCallManager.swift
//  Blue Call
//
//  Created by Tamara Bernad on 2017-06-16.
//  Copyright © 2017 Blue Call. All rights reserved.
//

import Foundation
import UIKit

#if NDEBUG
let SINAPSEnvironmentAutomatic = SINAPSEnvironment.production
#else
#if DEBUG
let SINAPSEnvironmentAutomatic = SINAPSEnvironment.development
#else
let SINAPSEnvironmentAutomatic = SINAPSEnvironment.production
#endif  // ifdef DEBUG
#endif  // ifdef NDEBUG


class SinchCallManager:NSObject{
    
    var inCall:Bool = false;
    var isCallKit: Bool{
        guard let _callKitProvider = callKitProvider, let _sinchCall = sinchCall else {return false}
        return _callKitProvider.callExists(_sinchCall)
    }
    var callDelegate:CallDelegate?
    var messageDelegate:SinchMessageDelegate?
    
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
    var isMessagingEnabled:Bool;
    init(_ messagingEnabled:Bool = true) {
        push = Sinch.managedPush(with: SINAPSEnvironmentAutomatic)
        isMessagingEnabled = messagingEnabled;
        super.init()

        self.push.delegate = self;
        self.push.setDesiredPushTypeAutomatically()
    }
    func initSinchClient(with userId:String){
        if(client == nil){
            UserDefaults.standard.set(userId, forKey: "userId");
            client = Sinch.client(withApplicationKey: "4a279d6c-4ebf-4dfc-9297-94c03e307f34", applicationSecret: "BCm/KEUAKU2PbpaukRzdGg==", environmentHost: "sandbox.sinch.com", userId: userId)
          
            client?.delegate = self
            client?.call().delegate = self
            if(self.isMessagingEnabled){
                messageDelegate = SinchMessageDelegate()
                messageDelegate?.messageClient = client?.messageClient();
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

        let notification:SINLocalNotification = SINLocalNotification();
//        notification.alertAction = "SIN_INCOMING_CALL".localized
//        notification.alertBody = NSString.localizedStringWithFormat("SIN_INCOMING_CALL_DISPLAY_NAME".localized as NSString, self.callerDisplayName) as String!;
        notification.soundName = "incoming.wav"
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
            
            self.showIncominMessageNotificationWithPayload(payload! as NSDictionary, senderId: result.messageResult().senderId)
            
            //only if the app is in background we want to increment the badges count withoug actully going to DB to check
//            if(UIApplication.shared.applicationState != .active){
//                BadgesMananger.instance.incrementMessagesCount()
//            }
        }
        
        
    }
    func showIncominMessageNotificationWithPayload(_ payload:NSDictionary, senderId:String){
        guard let _ = payload.value(forKey: "sin") else {return}
        guard let _aps = payload.value(forKey: "aps") as? NSDictionary else {return}
        guard let _alert = _aps.value(forKey: "alert") as? NSDictionary else {return}
        guard let args = _alert.value(forKey: "loc-args") as? NSArray else {return}
        guard let key = args.firstObject as? String else {return}

//        let not = UILocalNotification();
//        not.fireDate = Date();
//        not.alertTitle = "SIN_INCOMING_IM".localized;
//        not.alertBody = NSString.localizedStringWithFormat("SIN_INCOMING_IM_DISPLAY_NAME".localized as NSString, key) as String
//        not.timeZone = NSTimeZone.default
//        not.userInfo = ["deep-link":BCEnvironment.internalDeeplink(withPath: "\(Routes.chat.rawValue)/\(senderId)")]
//        UIApplication.shared.scheduleLocalNotification(not)
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
