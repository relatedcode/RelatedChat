#import <Foundation/Foundation.h>

// Persistence for high-level SINService

@class SINServiceConfig;

@interface SINSServicePersistence : NSObject

- (instancetype)initWithConfig:(SINServiceConfig *)config;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

@end
