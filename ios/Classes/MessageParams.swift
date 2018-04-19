//
//  MessageParams.swift
//  BlueCall
//
//  Created by Tamara Bernad on 2018-04-11.
//  Copyright © 2018 Blue Call. All rights reserved.
//

import Foundation
class MessageParams:NSObject{
    var text: String?
    var headers:[String: String]?;
//    var role:String?
//    var type:String?
    var senderId:String?
    var receiverIds:[String]?
//    var remoteUserId:String?
//    var timestamp:Date?;
    var messageId:String?
}
