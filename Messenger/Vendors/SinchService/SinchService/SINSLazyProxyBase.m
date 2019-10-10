#import "SINSLazyProxyBase.h"

@implementation SINSLazyProxyBase

- (void)assignDelegateToProxee:(id)delegate {
  if ([_proxee respondsToSelector:@selector(setDelegate:)]) {
    [_proxee setDelegate:delegate];
  }
}

- (void)setDelegate:(id)delegate {
  _delegate = delegate;
  [self assignDelegateToProxee:_delegate];
}

- (void)setProxee:(id)proxee {
  if (_proxee && (nil == proxee)) {
    [self willSetProxeeToNil:_proxee];
  }
  _proxee = proxee;
  if (_delegate) {
    [self assignDelegateToProxee:_delegate];
  } else {
    if ([_proxee respondsToSelector:@selector(delegate)]) {
      _delegate = [_proxee delegate];
    }
  }
}

- (void)willSetProxeeToNil:(id)proxee {
  // noop, subclass override
}

@end
