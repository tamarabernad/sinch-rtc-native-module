
#import "RNSinchRtc.h"
#import "RNSinchRtc-Swift.h"

@interface RNSinchRtc()<CallDelegate, MessagesDelegate>

@end
@implementation RNSinchRtc

- (instancetype)init{
    if(self = [super init]){
        PhoneActivityManager.instance.callManager.callDelegate = self;
        PhoneActivityManager.instance.callManager.messagesDelegate = self;
    }
    return self;
}
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    
    return @[RNEvent.CallDidChangeStatus,
             RNEvent.CallEndedWithReason,
             RNEvent.CallDidEstablish,
             RNEvent.CallDidProgress,
             RNEvent.MessageReceived,
             RNEvent.MessageSent,
             RNEvent.MessageDelivered,
             RNEvent.MessageFailed];
}


#pragma mark - User
RCT_EXPORT_METHOD(login:(NSString *)username)
{
    [PhoneActivityManager.instance login:username];
}

RCT_EXPORT_METHOD(setDisplayName:(NSString *)displayName)
{
    [PhoneActivityManager.instance setDisplayName:displayName];
}

#pragma mark - Sinch Client
RCT_EXPORT_METHOD(terminateGracefully)
{
    [PhoneActivityManager.instance terminateGracefully];
}

RCT_EXPORT_METHOD(terminate)
{
    [PhoneActivityManager.instance terminate];
}

#pragma mark - Call
RCT_EXPORT_METHOD(call:(NSString *)userId callback:(RCTResponseSenderBlock) callback)
{
    CallParams *params = [CallParams new];
    params.calleeId = userId;
    NSString *callId = [PhoneActivityManager.instance callWith:params];
    callback(@[callId]);
}

RCT_EXPORT_METHOD(anwer)
{
    [PhoneActivityManager.instance answer];
}

RCT_EXPORT_METHOD(hangup)
{
    [PhoneActivityManager.instance hangup];
}

#pragma mark - Instant Messages
RCT_EXPORT_METHOD(sendMessage:(NSString *)receiverUserId
                  text:(NSString *)text
                  headers:(NSDictionary *)headers
                  callback:(RCTResponseSenderBlock) callback)
{
    MessageParams *params = [MessageParams new];
    params.receiverIds = @[receiverUserId];
    params.text = text;
    params.headers = headers;
    
    MessageParams *result = [PhoneActivityManager.instance sendMessageWithParams:params];
    if(result){
        callback(@[result.messageId, result.receiverIds, result.text]);
    }
}

#pragma mark - Notifications
#pragma mark Notification Requesting
+ (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
}
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
      [PhoneActivityManager.instance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@:%@", NSStringFromSelector(_cmd), error);
}

#pragma mark Notification Handling
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
      [PhoneActivityManager.instance application:application didReceiveRemoteNotification:userInfo];
}

#pragma mark - CallDelegate
- (void)callDidChangeStatusWithStatus:(NSString * _Nonnull)status {
    NSLog(@"callDidChangeStatusWithStatus");
    [self sendEventWithName:RNEvent.CallDidChangeStatus body:status];
}

- (void)callDidEndWithReason:(NSString *)reason duration:(double)duration{
    [self sendEventWithName:RNEvent.CallEndedWithReason body:@{@"duration":@(duration), @"reason":reason}];
}

- (void)callDidEstablish {
    NSLog(@"callDidEstablish");
    [self sendEventWithName:RNEvent.CallDidEstablish body:nil];
}

- (void)callDidProgress {
    NSLog(@"callDidProgress");
    [self sendEventWithName:RNEvent.CallDidProgress body:nil];
}

#pragma mark - MessagesDelegate
- (void)didReceiveMessageWithMessageId:(NSString * _Nonnull)messageId headers:(NSDictionary * _Nonnull)headers senderId:(NSString * _Nonnull)senderId recipients:(NSArray * _Nonnull)recipients text:(NSString * _Nonnull)text date:(NSDate * _Nonnull)date {
    [self sendEventWithName:RNEvent.MessageReceived body:@{@"messageId":messageId,
                                                           @"headers":headers,
                                                           @"senderId":senderId,
                                                           @"recipients":recipients,
                                                           @"content":text,
                                                           @"timeStamp":date
                                                           }];
}

- (void)messageWasSentWithMessageId:(NSString * _Nonnull)messageId headers:(NSDictionary * _Nonnull)headers recipients:(NSArray * _Nonnull)recipients text:(NSString * _Nonnull)text date:(NSDate * _Nonnull)date {
    [self sendEventWithName:RNEvent.MessageSent body:@{@"messageId":messageId,
                                                           @"headers":headers,
                                                           @"recipients":recipients,
                                                           @"content":text,
                                                           @"timeStamp":date
                                                           }];
    
}

- (void)messageWasDeliveredWithMessageId:(NSString * _Nonnull)messageId recipient:(NSString * _Nonnull)recipient date:(NSDate * _Nonnull)date {
    [self sendEventWithName:RNEvent.MessageDelivered body:@{@"messageId":messageId,
                                                            @"recipient":recipient,
                                                            @"timeStamp":date
                                                            }];
}

- (void)messageFaildToDeliverWithMessageId:(NSString * _Nonnull)messageId headers:(NSDictionary * _Nonnull)headers recipients:(NSArray * _Nonnull)recipients text:(NSString * _Nonnull)text date:(NSDate * _Nonnull)date error:(NSError * _Nonnull)error {
        [self sendEventWithName:RNEvent.MessageFailed body:@{@"messageId":messageId,
                                                               @"headers":headers,
                                                               @"recipients":recipients,
                                                               @"content":text,
                                                               @"timeStamp":date,
                                                               @"error":error.localizedDescription
                                                               }];
}



@end
