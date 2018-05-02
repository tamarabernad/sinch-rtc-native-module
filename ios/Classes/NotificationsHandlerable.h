//
//  NotificationsHandlerable.h
//  RNSinchRtc
//
//  Created by Tamara Bernad on 2018-05-02.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NotificationsHandlerable <NSObject>
-(void) handleMessageNotificationWithPayload:(NSDictionary *) payload messageId:(NSString*)messageId senderId:(NSString*)senderId;
-(UILocalNotification *) notificationForIncomingCallWithDisplayName:(NSString *)displayName;
@end
