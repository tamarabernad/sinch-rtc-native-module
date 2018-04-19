//
//  CallManageable.swift
//  Blue Call
//
//  Created by Tamara Bernad on 2017-06-15.
//  Copyright © 2017 Blue Call. All rights reserved.
//

import Foundation
import UIKit

@objc enum CallDirection:Int {
    case incoming;
    case outgoing;
}
enum CallStatus:String{
    case none;
    case initiated;
    case progressing;
    case connecting;
    case connected;
    case finished;
}
class CallStatusObjC:NSObject{
    public static let none = CallStatus.none.rawValue
    public static let initiated = CallStatus.initiated.rawValue
    public static let progressing = CallStatus.progressing.rawValue
    public static let connecting = CallStatus.connecting.rawValue
    public static let connected = CallStatus.connected.rawValue
    public static let finished = CallStatus.finished.rawValue
}
enum CallResult:String{
    case declined;
    case timedout;
    case canceled;
    case noAnswer;
    case hangup;
    case broke;
    case error;
    case errorNoUser;
}
class CallResultObjC:NSObject{
    public static let declined = CallResult.declined.rawValue
    public static let timedout = CallResult.timedout.rawValue
    public static let noAnswer = CallResult.noAnswer.rawValue
    public static let canceled = CallResult.canceled.rawValue
    public static let hangup = CallResult.hangup.rawValue
    public static let error = CallResult.error.rawValue
    public static let errorNoUser = CallResult.errorNoUser.rawValue
}
@objc protocol CallManageable{
    
    func login(_ userId:String)
    func logout()
    func setDisplayName(_ name:String)
    //returns callId
    func call(with callParams:CallParams)->String?;
    func answer()
    func hangup()
    func sendMessage(params:MessageParams)->MessageParams?;
    func terminate();
    func terminateGracefully();
    
    var callDelegate:CallDelegate?{get set}
    var inCall:Bool{get set}
    var callDirection:CallDirection{get}
    var establishedTime:Date?{get}
    var callDuration:NSNumber?{get}
    var remoteUserId:String?{get}
    var callId:String?{get}
//    var level:String?{get}
    var call:Any?{get}
    var isCallKit:Bool {get}
    var isFirstFreeCall:Bool {get}
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data);
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any]);
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void);
//    func trackEvent(event:String);
//    func trackEvent(event: String, on screen:String);
    
    
    func internalMessageReceived(messageParams:MessageParams);
    func goOffline()
    func goOnline()
    
    
    
    func cutCall()
}
