#import "SINSServicePersistence.h"
#import "SINService.h"  // for SINServiceConfig

static NSString *const SINSServicePersistenceGlobalRootKey = @"SINSServicePersistenceGlobalRoot";

@interface SINServiceConfig (ApplicationKey)
- (NSString *)applicationKey;
@end

@implementation SINSServicePersistence {
  SINServiceConfig *_config;
  NSUserDefaults *_persistence;
}

- (instancetype)initWithConfig:(SINServiceConfig *)config {
  NSParameterAssert(config);
  self = [super init];
  if (self) {
    _config = config;
    _persistence = [NSUserDefaults standardUserDefaults];
  }
  return self;
}

- (NSString *)applicationKey {
  NSString *appKey = [_config applicationKey];
  NSAssert([appKey length], @"%@", @"");
  if ([appKey length] == 0) {
    [NSException raise:NSInternalInconsistencyException format:@"Invalid Sinch application key"];
  }
  return appKey;
}

- (NSUserDefaults *)persistence {
  NSParameterAssert(_persistence);
  return _persistence;
}

- (void)synchronize {
  // NSUserDefaults is thread safe, so lets dispatch to non-main thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [self.persistence synchronize]; });
}

- (NSDictionary *)globalRoot {
  NSDictionary *root = [self.persistence objectForKey:SINSServicePersistenceGlobalRootKey];
  if (root) {
    return root;
  }
  return [NSDictionary dictionary];
}

- (NSDictionary *)root {
  NSDictionary *appKeyRoot = [self.globalRoot objectForKey:self.applicationKey];
  if (appKeyRoot) {
    return appKeyRoot;
  }
  return [NSDictionary dictionary];
}

- (void)writeRoot:(NSDictionary *)appKeySpace {
  NSParameterAssert(appKeySpace);
  NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.globalRoot];
  [tmp setObject:appKeySpace forKey:self.applicationKey];
  [self.persistence setObject:tmp forKey:SINSServicePersistenceGlobalRootKey];
}

- (id)objectForKey:(NSString *)key {
  NSParameterAssert(key);
  return [[self root] objectForKey:key];
}

- (void)setObject:(id)value forKey:(NSString *)key {
  NSParameterAssert(value);
  NSParameterAssert(key);
  NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:[self root]];
  [tmp setObject:value forKey:key];
  [self writeRoot:tmp];
  [self synchronize];
}

- (void)removeObjectForKey:(NSString *)key {
  NSParameterAssert(key);
  NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:[self root]];
  [tmp removeObjectForKey:key];
  [self writeRoot:tmp];
  [self synchronize];
}

@end
