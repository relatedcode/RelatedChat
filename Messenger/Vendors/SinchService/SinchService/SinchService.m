#import "SinchService.h"
#import "SINService.h"

@protocol SINServicePrivate
- (id)initWithConfig:(SINServiceConfig *)config;
@end

@implementation SinchService

+ (id<SINService>)serviceWithConfig:(SINServiceConfig *)config {
  Class klazz = NSClassFromString(@"SINService");
  return [[klazz alloc] initWithConfig:config];
}

+ (SINServiceConfig *)configWithApplicationKey:(NSString *)applicationKey
                             applicationSecret:(NSString *)applicationSecret
                               environmentHost:(NSString *)environmentHost {
  return [[SINServiceConfig alloc] initWithApplicationKey:applicationKey
                                        applicationSecret:applicationSecret
                                          environmentHost:environmentHost];
}

@end
