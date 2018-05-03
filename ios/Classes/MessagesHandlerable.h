//
//  MessagesHandlerable.h
//  RNSinchRtc
//
//  Created by Tamara Bernad on 2018-05-02.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MessagesHandlerable <NSObject>
-(void) onIncomingMessageWithMessageId:(NSString *)messageId headers:(NSDictionary *)headers senderId:(NSString *)senderId recipients:(NSArray *)recipients text:(NSString *)text date:(NSDate *)date;
-(void) onSendingMessageWithMessageId:(NSString *)messageId headers:(NSDictionary *)headers senderId:(NSString *)senderId recipients:(NSArray *)recipients text:(NSString *)text date:(NSDate *)date;
@end
