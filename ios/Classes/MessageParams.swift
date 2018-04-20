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
    var senderId:String?
    var receiverIds:[String]?
    var messageId:String?
    
    override func copy() -> Any {
        let _copy = MessageParams();
        _copy.text = text
        _copy.headers = headers
        _copy.senderId = senderId
        _copy.receiverIds = receiverIds
        _copy.messageId = messageId
        return _copy
    }
}
