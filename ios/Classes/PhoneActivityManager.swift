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
    @objc static let instance = PhoneActivityManager()
    @objc var callManager:CallManageable?;
  
    private override init() {}
    
    @objc func initialize(props: [String : Any]){
        self.callManager = SinchCallManager(props: props)
    }
  
    var inCall:Bool{
        get{
            guard let _inCall = callManager?.inCall else {return false}
            return _inCall
        }
        set(_inCall){
            callManager?.inCall = _inCall
        }
    }
    @objc func login(_ userId:String){
        self.callManager?.login(userId)
    }
    @objc func logout(){
        self.callManager?.logout()
    }
    @objc func setDisplayName(_ name:String){
        self.callManager?.setDisplayName(name)
    }
    @objc func answer(){
        self.callManager?.answer()
    }
    @objc func hangup(){
        self.callManager?.hangup()
    }
    @objc func sendMessage(params:MessageParams)->MessageParams?{
        return self.callManager?.sendMessage(params: params)
    }
    @objc func terminate(){
        self.callManager?.terminate()
    }
    @objc func terminateGracefully(){
        self.callManager?.terminateGracefully()
    }
  
    @objc func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        self.callManager?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    @objc func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any]){
        self.callManager?.application(application, didReceiveRemoteNotification: userInfo)
    }
    @objc func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        self.callManager?.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    @objc func call(with callParams:CallParams)->String?{
        return self.callManager?.call(with: callParams)
    }
   
}
