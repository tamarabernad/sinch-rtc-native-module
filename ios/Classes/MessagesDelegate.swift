//
//  MessagesDelegate.swift
//  RNSinchRtc
//
//  Created by Tamara Bernad on 2018-04-20.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
@objc protocol MessagesDelegate{
    func didReceiveMessage(messageId:String, headers:[AnyHashable:Any], senderId:String, recipients:[Any], text:String, date:Date)
    func messageWasSent(messageId:String, headers:[AnyHashable:Any], recipients:[Any], text:String, date:Date)
    func messageWasDelivered(messageId:String, recipient:String, date:Date)
    func messageFaildToDeliver(messageId:String, headers:[AnyHashable:Any], recipients:[Any], text:String, date:Date, error:Error)
}
