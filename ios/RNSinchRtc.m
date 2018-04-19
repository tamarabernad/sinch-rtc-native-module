
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

// Sinch Client
RCT_EXPORT_METHOD(terminateGracefully)
{
    [PhoneActivityManager.instance terminateGracefully];
}

RCT_EXPORT_METHOD(terminate)
{
    [PhoneActivityManager.instance terminate];
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
    MessageParams *params = [MessageParams new];
    params.receiverIds = @[receiverUserId];
    params.text = text;
    params.headers = headers;
    
    MessageParams *result = [PhoneActivityManager.instance sendMessageWithParams:params];
    if(result){
        callback(@[result.messageId, result.receiverIds, result.text]);
    }
}

@end
  
