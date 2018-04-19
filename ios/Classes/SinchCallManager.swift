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
//    public struct Notification{
//        static let didReceiveCall = NSNotification.Name(kCallDidReceiveCall);
//    }
  
    var callDirection: CallDirection{
        return self.sinchCall?.direction == .incoming ? .incoming : .outgoing;
    }
    var establishedTime: Date?{
        return self.sinchCall?.details.establishedTime
    }
    var callDuration:NSNumber?{
        guard let begin = sinchCall?.details.establishedTime,let end = sinchCall?.details.endedTime else {
            return nil;
        }
        
        return NSNumber(value: end.timeIntervalSince(begin))
    }
    var remoteUserId: String?{
        return self.sinchCall?.remoteUserId
    }
    var callId: String?{
        return self.sinchCall?.callId
    }
//    var level: String?{
//        return self.callLevel
//    }
    var isCallKit: Bool{
        guard let _callKitProvider = callKitProvider, let _sinchCall = sinchCall else {return false}
        return _callKitProvider.callExists(_sinchCall)
    }
    var callDelegate:CallDelegate?
    var messageDelegate:SinchMessageDelegate?
    
    var sinchCall:SINCall?;
    var callStatus:CallStatus = .none {
        didSet {
            self.callDelegate?.callDidChangeStatus(status: callStatus.rawValue)
        }
    }
    var call:Any?;
//    var callLevel:String = "";
    var callParams:CallParams?;
//    var callPaymentSourceId:String?;
  
    var push:SINManagedPush;
    var client:SINClient?;
    var callKitProvider:SINCallKitProvider?;
    var inCall:Bool = false;
    var remoteNotificationIncomingDisplayName:String?;
    var callerDisplayName:String{
        get{
            guard let _remote = remoteNotificationIncomingDisplayName else {
                return "BlueCaller"
            }
            return _remote;
        }
    }
    var userId:String?;
    
    var logNotes:String = "";
    var isMessagingEnabled:Bool;
    var audioController:PhoneAudioController = PhoneAudioController();
    
    var eventCallPayment:String{
        guard let _params = callParams else { return "unknown" }
        return _params.isFirstFreeCall ? "first-free-call" : "standard"
    }
    var isFirstFreeCall:Bool{
        guard let _params = callParams else { return false }
        return _params.isFirstFreeCall;
    }
    
    init(_ messagingEnabled:Bool = false) {
        push = Sinch.managedPush(with: SINAPSEnvironmentAutomatic)
        isMessagingEnabled = messagingEnabled;
        super.init()

        self.push.delegate = self;
        self.push.setDesiredPushTypeAutomatically()
    }
    func addLogNote(note:String){
        logNotes.append(note);
        logNotes.append(";");
    }
    func flushLogNote(){
        logNotes = "";
    }
    func initSinchClient(with userId:String){
        if(client == nil){
            UserDefaults.standard.set(userId, forKey: "userId");
//            client = Sinch.client(withApplicationKey: BCEnvironment.sinchAppKey(), applicationSecret: BCEnvironment.sinchAppSecret(), environmentHost: BCEnvironment.sinchEnvHost(), userId: userId)
//
//            if let user = BCDataProvider.loggedInUser(){
//                self.push.setDisplayName(user.displayName())
//            }
          
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
//        guard let status = DataProvider.installation().userStatus else {return false}
//        return BCUser.disabledReceiveIncomingCallsStatus(status);
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
        if(!self.isCallKit){
            self.audioController.playIncomingCall();
        }
        self.callKitProvider?.reportNewIncomingCall(call, withDisplayName: self.callerDisplayName);
       // NotificationCenter.default.post(name: Notification.didReceiveCall, object: nil, userInfo: nil)
        self.callStatus = .progressing
    }
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        if(!self.canReceiveIncomingCall()){return;}
        self.sinchCall = call;
        self.sinchCall?.delegate = self
        self.callKitProvider?.reportNewIncomingCall(call, withDisplayName: self.callerDisplayName);
        self.callStatus = .progressing
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
        self.audioController.startCallVibration(repeatCount: 5);
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
            guard let callResult = result.call() else{return;}
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
        self.userId = userId;
        self.initSinchClient(with: userId)
    }
    func setDisplayName(_ name:String){
        self.push.setDisplayName(name);
    }
    func call(with callParams: CallParams)->String? {
        
        guard let call = self.client?.call().callUser(withId: callParams.calleeId) else {return nil;}
        self.sinchCall = call;
        self.sinchCall?.delegate = self
        //        self.callLevel = callParams.level;
        //        self.callPaymentSourceId = callParams.paymentSourceId;
        self.callParams = callParams;
        self.flushLogNote();
        
        //        BCDataProvider.beginCall(withProviderCallId: call.callId, receiverId: call.remoteUserId , andLevel: self.callLevel, andPaymentSourceId: self.callPaymentSourceId, withCompletion: { (result, error) in
        //            if((error) != nil){return;}
        //            guard let _result = result as? BCCallInfo else{
        //                self.call = nil;
        //                return;
        //            }
        //            self.call = _result;
        //            self.call?.persist();
        //            self.callDelegate?.callWasStored()
        //        })
        self.callStatus = .initiated
        return call.callId;
        //NotificationCenter.default.post(name: Notification.didReceiveCall, object: nil, userInfo: nil)
    }
    func answer() {
        self.audioController.stopCallSound();
        self.addLogNote(note: "call-answer");
        self.sinchCall?.answer()
        self.callStatus = .connecting
    }
    func hangup() {
        self.audioController.stopCallSound();
        
        self.addLogNote(note: "call-hangup");
        self.sinchCall?.hangup()
    }
    func sendMessage(params:MessageParams)->MessageParams?{
        if(client == nil){
            //TODO: move to a method
            if let userId = UserDefaults.standard.object(forKey: "userId"){
                initSinchClient(with: userId as! String);
            }
        }
        return self.messageDelegate?.sendMessage(params: params)
    }
    
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        //    if(_hasRegisteredNotfications)return;
        //    _hasRegisteredNotfications = YES;
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
    
    
    func internalMessageReceived(messageParams:MessageParams){
        self.messageDelegate?.internalMessageReceived(messageParams: messageParams);
    }
    func goOffline(){
    }
    func goOnline(){
    }
    
    func logout(){
        self.client?.unregisterPushNotificationDeviceToken()
        self.client?.stopListeningOnActiveConnection()
        self.client = nil;
    }
    
    
    func cutCall() {
        self.audioController.stopCallSound();
        
        self.addLogNote(note: "call-cut");
        self.sinchCall?.hangup()
    }
}
extension SinchCallManager:SINCallDelegate{
    func callDidProgress(_ call: SINCall!) {
        audioController.playOutgoingCall()
        self.callDelegate?.callDidProgress()
        self.callStatus = .progressing
    }
    func callDidEnd(_ call: SINCall!) {
        audioController.stopCallSound()
        
        inCall = false;
        let status:CallStatus = .finished;
        var result:CallResult;
        
        var reason:CallEndReason;
        if let error = call.details.error as NSError?{

            self.addLogNote(note: error.localizedDescription)
            
            if (error.code == 4000){
                reason = .errorNoUser;
                result = .errorNoUser;
            }else{
                reason = .errorGeneral;
                result = .error   
            }
        }else{
            let cause = call.details.endCause;
            switch cause {
            case .canceled:
                reason = .canceled
                result = .canceled
                break;
            case .noAnswer:
                reason = .noAnswer
                result = .noAnswer
                break;
            case .denied:
                reason = .declined
                result = .declined
                break;
            case .timeout:
                reason = .timeout
                result = .timedout
                break;
            case .hungUp:
                reason = .hangup
                result = .hangup
                break;
            default:
                reason = .errorGeneral
                result = .error
            }
        }
//        if let _callId = self.call?.uid, let _sinchCall = self.sinchCall, _sinchCall.direction == .outgoing
//        {
//            self.addLogNote(note: result.rawValue)
//            self.addLogNote(note: status.rawValue)
////
////            self.call?.result = result.rawValue;
////            self.call?.status = status.rawValue;
////            self.call?.note = self.logNotes;
////            self.call?.persist()
//
//        }
        self.callDelegate?.callDidEnd(reason: reason)
        self.callKitProvider?.reportCallEnded(call)
        self.callStatus = .finished
        self.remoteNotificationIncomingDisplayName = nil;
    }
    func callDidEstablish(_ call: SINCall!) {
        audioController.stopCallSound()
        
        inCall = true;
        
//        if let _callId = self.call?.uid, let _sinchCall = self.sinchCall, _sinchCall.direction == .outgoing
//        {
//            self.addLogNote(note: "call-established")
//            let status:CallStatus = .connected;
//            self.call?.status = status.rawValue;
//            self.call?.note = self.logNotes;
//            self.call?.persist()
////            BCDataProvider.updateCall(withUid: _callId, status: status.rawValue, andResult: nil, andNote: nil, withCompletion: nil);
//        }
//        BCDataProvider.setLineStatus(BCUser.lineStatusBusy(), withCompletion: nil)
      
        self.callDelegate?.callDidEstablish()
        self.callStatus = .connected
    }
    
}
