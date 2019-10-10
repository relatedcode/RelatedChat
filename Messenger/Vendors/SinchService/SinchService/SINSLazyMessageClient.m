#import "SINSLazyMessageClient.h"
#import <Sinch/Sinch.h>
#import "SINSParameterValidation.h"
#import "SINServiceError.h"

@interface SINSMessageFailureInfo : NSObject <SINMessageFailureInfo>
@property (nonatomic, readwrite, copy) NSString *messageId;
@property (nonatomic, readwrite, copy) NSString *recipientId;
@property (nonatomic, readwrite, copy) NSError *error;
@end

@implementation SINSMessageFailureInfo
@end

@interface SINSFailedOutgoingMessage : NSObject <SINMessage>
@property (nonatomic, readonly) NSDate *timestamp;
@end

@implementation SINSFailedOutgoingMessage {
  __strong SINOutgoingMessage *_message;
}

- (instancetype)initWithMessage:(SINOutgoingMessage *)message {
  self = [super init];
  if (self) {
    _timestamp = [NSDate date];
    _message = message;
  }
  return self;
}

- (NSString *)messageId {
  return [_message messageId];
}

- (NSArray *)recipientIds {
  return [_message recipientIds];
}

- (NSString *)senderId {
  return @"";  // unknown because SINClient not created yet
}

- (NSString *)text {
  return [_message text];
}

- (NSDictionary *)headers {
  return [_message headers];
}

@end

@implementation SINSLazyMessageClient

- (void)sendMessage:(SINOutgoingMessage *)message {
  SINSParameterCondition(message);

  if (self.proxee) {
    [self.proxee sendMessage:message];
  } else {
    [self failMessage:message];
  }
}

- (void)failMessage:(SINOutgoingMessage *)message {
  NSParameterAssert(message);

  for (NSString *recipientId in [message recipientIds]) {
    SINSMessageFailureInfo *info = [[SINSMessageFailureInfo alloc] init];
    info.messageId = [message messageId];
    info.recipientId = recipientId;
    info.error = SINServiceComponentNotAvailableError();
    [self.delegate messageFailed:[[SINSFailedOutgoingMessage alloc] initWithMessage:message] info:info];
  }
}

@end
