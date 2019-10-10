#import "SINSLazyCallClient.h"
#import "SINServiceError.h"
#import <Sinch/Sinch.h>

// SINFailedCall represents an immediately failed call. E.g. when trying to initiate a call before a SINClient is
// completely initialized and started.

@interface SINSFailedCall : NSObject <SINCall, SINCallDetails>
@property (nonatomic, readonly, copy) NSString *remoteUserId;
// SINCallDetails
@property (nonatomic, readonly, strong) NSDate *startedTime;
@property (nonatomic, readonly, strong) NSDate *establishedTime;
@property (nonatomic, readonly, strong) NSDate *endedTime;
@property (nonatomic, readonly) UIApplicationState applicationStateWhenReceived;
@end

@implementation SINSFailedCall

@synthesize userInfo = _userInfo;  // -[SINCall userInfo]
@synthesize headers = _headers;
@synthesize delegate = _delegate;

- (instancetype)init {
  [NSException raise:NSInternalInconsistencyException format:@"Use designated initializer"];
  return nil;
}

- (instancetype)initWithUserId:(NSString *)userId headers:(NSDictionary *)headers {
  self = [super init];
  if (self) {
    _remoteUserId = userId;
    _headers = headers;
    _startedTime = [NSDate date];
    _endedTime = _startedTime;
    _establishedTime = nil;
    _applicationStateWhenReceived = [[UIApplication sharedApplication] applicationState];
  }
  return self;
}

- (NSString *)callId {
  return @"";
}

- (SINCallState)state {
  return SINCallStateEnded;
}

- (SINCallDirection)direction {
  return SINCallDirectionOutgoing;
}

- (id<SINCallDetails>)details {
  return self;
}

- (void)setDelegate:(id<SINCallDelegate>)delegate {
  _delegate = delegate;
  if (_delegate) {
    [_delegate callDidEnd:self];
  }
}

- (void)sendDTMF:(NSString *)key {
  // noop
}

- (void)hangup {
  // noop
}

- (void)answer {
  // noop
}

#pragma mark - SINCallDetails

- (SINCallEndCause)endCause {
  return SINCallEndCauseError;
}

- (NSError *)error {
  return SINServiceComponentNotAvailableError();
}

@end

@implementation SINSLazyCallClient

- (id<SINCall>)callUserWithId:(NSString *)userId {
  return [self callUserWithId:userId headers:@{}];
}

- (id<SINCall>)callUserWithId:(NSString *)userId headers:(NSDictionary *)headers {
  if (self.proxee) {
    return [self.proxee callUserWithId:userId headers:headers];
  } else {
    return [[SINSFailedCall alloc] initWithUserId:userId headers:headers];
  }
}

- (id<SINCall>)callPhoneNumber:(NSString *)phoneNumber {
  return [self callPhoneNumber:phoneNumber headers:@{}];
}

- (id<SINCall>)callPhoneNumber:(NSString *)phoneNumber headers:(NSDictionary *)headers {
  if (self.proxee) {
    return [self.proxee callPhoneNumber:phoneNumber headers:headers];
  } else {
    return [[SINSFailedCall alloc] initWithUserId:phoneNumber headers:headers];
  }
}

@end