#import <Foundation/Foundation.h>

@interface SINSLazyProxyBase : NSObject

@property (nonatomic, strong) id proxee;
@property (nonatomic, weak) id delegate;  // support if proxee can have a delegate

- (void)willSetProxeeToNil:(id)proxee;  // subclass override hook

@end
