
#import "RNSinchRtc.h"
#import "RNSinchRtc-Swift.h"

@implementation RNSinchRtc

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

// User
RCT_EXPORT_METHOD(login:(NSString *)username)
{
    [PhoneActivityManager.instance login:username];
}

RCT_EXPORT_METHOD(setDisplayName:(NSString *)displayName)
{
    [PhoneActivityManager.instance setDisplayName:displayName];
}

// Call
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

// Instant Messages
RCT_EXPORT_METHOD(sendMessage:(NSString *)receiverUserId
                  text:(NSString *)text
                  headers:(NSDictionary *)headers
                  callback:(RCTResponseSenderBlock) callback)
{
//    CallParams *params = [CallParams new];
//    params.calleeId = userId;
//    NSString *callId = [PhoneActivityManager.instance callWith:params];
//    callback(@[callId]);
}

@end
  
