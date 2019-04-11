//
//  RNEvents.swift
//  RNSinchRtc
//
//  Created by Tamara Bernad on 2018-04-19.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

class RNEvent:NSObject{
    @objc public static let CallDidChangeStatus = "callDidChangeStatus"
    @objc public static let CallEndedWithReason = "callEndedWithReason"
    @objc public static let CallDidEstablish = "callDidEstablish"
    @objc public static let CallDidProgress = "callDidProgress"
    
    @objc public static let MessageReceived = "didReceiveMessage"
    @objc public static let MessageSent = "didSendMessage"
    @objc public static let MessageDelivered = "didDeliverMessage"
    @objc public static let MessageFailed = "didFailMessage"
}
