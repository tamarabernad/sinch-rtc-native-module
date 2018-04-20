//
//  RNEvents.swift
//  RNSinchRtc
//
//  Created by Tamara Bernad on 2018-04-19.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

class RNEvent:NSObject{
    public static let CallDidChangeStatus = "callDidChangeStatus"
    public static let CallEndedWithReason = "callEndedWithReason"
    public static let CallDidEstablish = "callDidEstablish"
    public static let CallDidProgress = "callDidProgress"
    
    public static let MessageReceived = "didReceiveMessage"
    public static let MessageSent = "didSendMessage"
    public static let MessageDelivered = "didDeliverMessage"
    public static let MessageFailed = "didFailMessage"
}
