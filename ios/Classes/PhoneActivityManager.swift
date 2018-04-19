//
//  PhoneActivityManager.swift
//  Blue Call
//
//  Created by Tamara Bernad on 2017-06-16.
//  Copyright © 2017 Blue Call. All rights reserved.
//

import Foundation
import UIKit

class PhoneActivityManager:NSObject{
    static let instance = PhoneActivityManager()
    var callManager:CallManageable;
  
    private override init() {
      self.callManager = SinchCallManager()
    }
  
    var inCall:Bool{
        get{
            return callManager.inCall
        }
        set(_inCall){
            callManager.inCall = _inCall
        }
    }
    func login(_ userId:String){
        self.callManager.login(userId)
    }
    func setDisplayName(_ name:String){
        self.callManager.setDisplayName(name)
    }
    func answer(){
        self.callManager.answer()
    }
    func hangup(){
        self.callManager.hangup()
    }
    func sendMessage(params:MessageParams){
        self.callManager.sendMessage(params: params)
    }
    
    
  
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        self.callManager.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any]){
        self.callManager.application(application, didReceiveRemoteNotification: userInfo)
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        self.callManager.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func call(with callParams:CallParams)->String?{
        return self.callManager.call(with: callParams)
    }
    
    func internalMessageReceived(messageParams:MessageParams){
        self.callManager.internalMessageReceived(messageParams: messageParams);
    }
    func goOffline(){
        self.callManager.goOffline()
    }
    func goOnline(){
        self.callManager.goOnline()
    }
    func logout(){
        self.callManager.logout()
    }
   
}
