
#import "SINCallKitProvider.h"
#import "AudioControllerDelegate.h"
#import <Sinch/Sinch.h>
#import "RNSinchRtc-Swift.h"

static CXCallEndedReason SINGetCallEndedReason(SINCallEndCause cause) {
  switch (cause) {
    case SINCallEndCauseError:
      return CXCallEndedReasonFailed;
    case SINCallEndCauseDenied:
      return CXCallEndedReasonRemoteEnded;
    case SINCallEndCauseHungUp:
      // This mapping is not really correct, as SINCallEndCauseHungUp is the end case also when the local peer ended the
      // call.
      return CXCallEndedReasonRemoteEnded;
    case SINCallEndCauseTimeout:
      return CXCallEndedReasonUnanswered;
    case SINCallEndCauseCanceled:
      return CXCallEndedReasonUnanswered;
    case SINCallEndCauseNoAnswer:
      return CXCallEndedReasonUnanswered;
    case SINCallEndCauseOtherDeviceAnswered:
      return CXCallEndedReasonUnanswered;
    default:
      break;
  }
  return CXCallEndedReasonFailed;
}

@interface SINCallKitProvider () <SINCallDelegate> {
  id<SINClient> _client;
  CXProvider *_provider;
  AudioContollerDelegate *_acDelegate;
  id<SINCall> _call;
  BOOL _muted;
}
@end

@implementation SINCallKitProvider
- (id<CallManageable>)callManager{
  return PhoneActivityManager.instance.callManager;
}
- (instancetype)initWithClient:(id<SINClient>)client {
  self = [super init];
  if (self) {
      _client = client;
      _muted = NO;
      _acDelegate = [[AudioContollerDelegate alloc] init];
      _client.audioController.delegate = _acDelegate;
      CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:@"BlueCall"];
      config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"ic-callkit-logo"]);
      if(@available(iOS 11.0, *)) {
          [config setIncludesCallsInRecents:NO];
      }
      config.ringtoneSound =[[NSBundle  mainBundle] pathForResource:@"incoming" ofType:@"wav"];
      config.maximumCallGroups = 1;
      config.maximumCallsPerCallGroup = 1;

      _provider = [[CXProvider alloc] initWithConfiguration:config];
      [_provider setDelegate:self queue:nil];
  }
  return self;
}

- (void)reportNewIncomingCall:(id<SINCall>)call withDisplayName:(NSString *)displayName {
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:displayName];
    update.localizedCallerName = displayName;
    update.supportsGrouping = NO;
    update.supportsHolding = NO;
    update.supportsUngrouping = NO;

  [_provider reportNewIncomingCallWithUUID:[[NSUUID alloc] initWithUUIDString:call.callId]
                                    update:update
                                completion:^(NSError *_Nullable error) {
                                  if (!error) {
                                    _call = call;
                                  }
                                }];
}

- (void)reportCallEnded:(id<SINCall>)call {
  if (call) {
    CXCallEndedReason reason = SINGetCallEndedReason(call.details.endCause);
    [_provider reportCallWithUUID:[[NSUUID alloc] initWithUUIDString:call.callId]
                      endedAtDate:call.details.endedTime
                           reason:reason];
  }
    _call = nil;
}

- (void)addNewCall:(id<SINCall>)call {
  NSLog(@"Adding: new call found (%@)", call.callId);
}

#pragma mark - CXProviderDelegate

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
  [_client.callClient provider:provider didActivateAudioSession:audioSession];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    [[self callManager] answer];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kCallDidReceiveCall object:nil];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    [[self callManager] hangup];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
  NSLog(@"-[CXProviderDelegate performSetMutedCallAction:]");

  if (_acDelegate.muted) {
    [[_client audioController] unmute];
  } else {
    [[_client audioController] mute];
  }

  [action fulfill];
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
  NSLog(@"-[CXProviderDelegate didDeactivateAudioSession:]");
}

- (void)providerDidReset:(CXProvider *)provider {
  NSLog(@"-[CXProviderDelegate providerDidReset:]");
}

- (BOOL)callExists:(id<SINCall>) call {
    return _call.callId == call.callId;
}

@end
