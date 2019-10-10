#import "SINSLazyAudioController.h"

#define WARN_AND_RETURN_ON_NO_PROXEE() \
  if (![self proxee]) {                \
    [self logNoProxeeAvailable];       \
    return;                            \
  }

@implementation SINSLazyAudioController

- (void)dealloc {
  if (self.proxee) {
    [self willSetProxeeToNil:self.proxee];
  }
}

- (void)willSetProxeeToNil:(id)proxee {
  if ([proxee respondsToSelector:@selector(invalidate)]) {
    [proxee invalidate];
  }
}

- (void)logNoProxeeAvailable {
  NSLog(@"WARNING: No underlying SINAudioController available");
}

#pragma mark - SINAudioController

- (void)unmute {
  WARN_AND_RETURN_ON_NO_PROXEE();
  [self.proxee unmute];
}

- (void)mute {
  WARN_AND_RETURN_ON_NO_PROXEE();
  [self.proxee mute];
}

- (void)startPlayingSoundFile:(NSString *)path loop:(BOOL)loop {
  WARN_AND_RETURN_ON_NO_PROXEE();
  [self.proxee startPlayingSoundFile:path loop:loop];
}

- (void)enableSpeaker {
  WARN_AND_RETURN_ON_NO_PROXEE();
  [self.proxee enableSpeaker];
}

- (void)disableSpeaker {
  WARN_AND_RETURN_ON_NO_PROXEE();
  [self.proxee disableSpeaker];
}

- (void)stopPlayingSoundFile {
  WARN_AND_RETURN_ON_NO_PROXEE();
  [self.proxee stopPlayingSoundFile];
}

@end
