//
//  SinchMessageDelegate.swift
//  Blue Call
//
//  Created by Tamara Bernad on 14/10/16.
//  Copyright © 2016 Blue Call. All rights reserved.
//

import Foundation

class SinchMessageDelegate:NSObject{
    
    var messageClient:SINMessageClient?{
        didSet {
            messageClient?.delegate = self;
        }
    }
    struct Notification {
        static let failed = Foundation.Notification.Name(rawValue: "SinchMessageDelegate.Notification.failed");
        static let received = Foundation.Notification.Name(rawValue: "SinchMessageDelegate.Notification.received");
        static let sent = Foundation.Notification.Name(rawValue: "SinchMessageDelegate.Notification.sent");
        static let delivered = Foundation.Notification.Name(rawValue: "SinchMessageDelegate.Notification.delivered");
        //static let send = Foundation.Notification.Name(rawValue: "SinchMessageDelegate.Notification.send");
        static let updateRead = Foundation.Notification.Name(rawValue: "SinchMessageDelegate.Notification.update-read");
    }
    
    // Objective-C bridge
    public static var NotificationReceived:String {
        get{
            return Notification.received.rawValue
        }
    }
    public static var NotificationUpdateRead:String {
        get{
            return Notification.updateRead.rawValue
        }
    }
    public func internalMessageReceived(messageParams:MessageParams){
//        guard let text = messageParams.text else {return;}
//        guard let role = messageParams.role else {return;}
//        guard let type = messageParams.type else {return;}
//        guard let senderId = messageParams.senderId else {return;}
//        guard let receiverId = messageParams.receiverId else {return;}
//        guard let remoteUserId = messageParams.remoteUserId else {return;}
//        guard let timestamp = messageParams.timestamp else {return;}
//        guard let messageId = messageParams.messageId else {return;}
        
        
//        let m = Message.makeFromId(messageId)
//        m.id = messageId
//        m.text = text
//        m.senderId = senderId
//        m.sentAt = timestamp
//        m.remoteUserId = remoteUserId
//        m.receiverId = receiverId
//        m.role = role
//        m.type = type
//        m.persist()
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: Notification.received, object: nil, userInfo: ["message":m])
//        }
    }
}
extension SinchMessageDelegate:SINMessageClientDelegate{

    func sendMessage(params:MessageParams)->MessageParams?{
        guard let _receivers = params.receiverIds else {return nil};
        guard let _text = params.text else {return nil};
        
        let message = SINOutgoingMessage(recipients: _receivers, text: _text)
        
        if let _headers = params.headers {
            for header in _headers{
                message?.addHeader(withValue: header.value, key: header.key)
            }
        }
            
        guard let _client = self.messageClient else {return nil;}
        _client.send(message)
        
        let result = params.copy() as! MessageParams
        result.messageId = message?.messageId;
        return result;
        
//        var m:Message? = nil
//        if let _message = message{
//            m = Message.makeFromId(_message.messageId)
//            m?.id = _message.messageId
//            m?.receiverId = receiverId
//            m?.senderId = BCDataProvider.loggedInUser()?.callerId
//            m?.role = BCDataProvider.loggedInUser()?.role()
//            m?.type = type;
//            m?.text = text;
//            m?.remoteUserId = receiverId;
//            m?.sessionId = sessionId;
//            m?.persist()
//        }
//
//        if let _completion = completion{
//            print("Did receive message \(m?.sentAt)")
//            _completion(m,nil);
//        }
//
    }
    func messageClient(_ messageClient:SINMessageClient!, didReceiveIncomingMessage message: SINMessage!) {
        print("Did receive message \(message.text)")
        var role:String?;
        var type:String?;
        if let _headers = message.headers{
            if let _role = _headers["role"] as? String{
                role = _role;
            }
            if let _type = _headers["type"] as? String{
                type = _type;
            }
        }
        
        
//        let m = Message.makeFromId(message.messageId)
//        m.id = message.messageId
//        m.text = message.text
//        m.senderId = message.senderId
//        m.sentAt = message.timestamp
//        m.remoteUserId = message.senderId
//        m.receiverId = BCDataProvider.loggedInUser()?.callerId
//        m.role = role
//        m.type = type
//        m.persist()
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: Notification.received, object: nil, userInfo: ["message":m])
//        }
    }
    func messageSent(_ message: SINMessage!, recipientId: String!) {
        print("messageSent \(message.timestamp)")
        guard let _messageId = message.messageId else {return}
        
//        let m = Message.makeFromId(_messageId)
//        m.id = _messageId
//        m.text = message.text
//        m.senderId = message.senderId
//        m.sentAt = message.timestamp
//        m.receiverId = recipientId
//        m.remoteUserId = recipientId
//        m.status = Message.statusSent
//        m.persist()
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: Notification.sent, object: nil, userInfo: ["message":m])
//        }
    }
    func message(_ message: SINMessage!, shouldSendPushNotifications pushPairs: [Any]!) {
        
    }
    func messageDelivered(_ info: SINMessageDeliveryInfo!) {
//        print("messageDelivered \(info.messageId)")
//        let m = Message.makeFromId(info.messageId)
//        m.status = Message.statusDelivered
//        m.persist()
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: Notification.delivered, object: nil, userInfo: ["message":m])
//        }
    }
    public func messageFailed(_ message: SINMessage!, info messageFailureInfo: SINMessageFailureInfo!) {
//        print("messageFailed \(messageFailureInfo.error)")
//        let m = Message.makeFromId(message.messageId)
//        m.status = Message.statusFailed
//        m.persist()
//
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: Notification.failed, object: nil, userInfo: ["message":m])
//        }
      
    }
}
