//
//  MessageParams.swift
//  BlueCall
//
//  Created by Tamara Bernad on 2018-04-11.
//  Copyright © 2018 Blue Call. All rights reserved.
//

import Foundation
class MessageParams:NSObject{
    @objc var text: String?
    @objc var headers:[String: String]?;
    @objc var senderId:String?
    @objc var receiverIds:[String]?
    @objc var messageId:String?
    
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
