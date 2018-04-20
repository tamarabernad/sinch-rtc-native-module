//
//  CallManageable.swift
//  Blue Call
//
//  Created by Tamara Bernad on 2017-06-15.
//  Copyright © 2017 Blue Call. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CallManageable{
    var callDelegate:CallDelegate?{get set}
    var messagesDelegate:MessagesDelegate?{get set}
    
    func login(_ userId:String)
    func logout()
    func setDisplayName(_ name:String)
    func call(with callParams:CallParams)->String?;
    func answer()
    func hangup()
    func sendMessage(params:MessageParams)->MessageParams?;
    func terminate();
    func terminateGracefully();
    var inCall:Bool{get set}

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data);
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any]);
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void);
}
