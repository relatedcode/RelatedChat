#import "SINService.h"
#import <Sinch/Sinch.h>
#import "SINSLazyCallClient.h"
#import "SINSLazyAudioController.h"
#import "SINSLazyMessageClient.h"
#import "SINSClientsObserver.h"
#import "SINSServicePersistence.h"
#import "SINSParameterValidation.h"
#import "SINServiceError.h"

static NSString *const SINServiceUserIdKey = @"userId";

@interface SINServiceConfig ()
@property (nonatomic, copy, readwrite) NSString *applicationKey;
@property (nonatomic, copy, readwrite) NSString *applicationSecret;
@property (nonatomic, copy, readwrite) NSString *environmentHost;
@property (nonatomic, assign) BOOL calling;
@property (nonatomic, assign) BOOL messaging;
@property (nonatomic, assign) BOOL managedPushNotifications;
@property (nonatomic, assign) SINAPSEnvironment apsEnvironment;
@property (nonatomic, assign) BOOL activeConnection;  // maps to -[SINClient startListeningOnActiveConnection]
@property (nonatomic, assign) BOOL activeConnectionInBackground;
@end

@implementation SINServiceConfig

- (instancetype)init {
  [NSException raise:NSInternalInconsistencyException format:@"Use designated initializer"];
  return nil;
}

- (instancetype)initWithApplicationKey:(NSString *)applicationKey environmentHost:(NSString *)environmentHost {
  return [self initWithApplicationKey:applicationKey applicationSecret:@"" environmentHost:environmentHost];
}
- (instancetype)initWithApplicationKey:(NSString *)applicationKey
                     applicationSecret:(NSString *)applicationSecret
                       environmentHost:(NSString *)environmentHost {
  self = [super init];
  if (self) {
    _applicationKey = [applicationKey copy];
    _environmentHost = [environmentHost copy];
    _applicationSecret = [applicationSecret copy];

    // Feature defaults
    _calling = YES;
    _messaging = YES;
    _activeConnection = YES;
  }
  return self;
}

+ (instancetype)config {
  return [[SINServiceConfig alloc] init];
}

- (instancetype)applicationKey:(NSString *)applicationKey {
  self.applicationKey = applicationKey;
  return self;
}

- (instancetype)environmentHost:(NSString *)environmentHost {
  self.environmentHost = environmentHost;
  return self;
}

- (instancetype)disableCalling {
  self.calling = NO;
  return self;
}

- (instancetype)disableMessaging {
  self.messaging = NO;
  return self;
}

- (instancetype)pushNotificationsWithEnvironment:(SINAPSEnvironment)apsEnvironment {
  self.managedPushNotifications = YES;
  self.apsEnvironment = apsEnvironment;
  return self;
}

- (instancetype)enableActiveConnectionInBackground {
  self.activeConnectionInBackground = YES;
  return self;
}

- (instancetype)disableActiveConnection {
  self.activeConnection = NO;
  return self;
}

@end

#pragma mark -

@interface SINService : NSObject <SINService, SINClientDelegate>
@property (nonatomic, strong, readonly) SINServiceConfig *config;
@property (nonatomic, strong, readonly) SINSServicePersistence *persistence;
@property (nonatomic, strong, readonly) SINSClientsObserver *clientsObserver;
@property (nonatomic, strong, readwrite) id<SINClient> client;
@property (nonatomic, strong, readwrite) id<SINManagedPush> push;
@property (nonatomic, strong, readonly) SINSLazyCallClient *callClient;
@property (nonatomic, strong, readonly) SINSLazyMessageClient *messageClient;
@property (nonatomic, strong, readonly) SINSLazyAudioController *audioController;
@end

@implementation SINService {
  BOOL _delegateRespondsToLogCallback;
}

@synthesize delegate = _delegate;

- (instancetype)init {
  [NSException raise:NSInternalInconsistencyException format:@"Use designated initializer"];
  return nil;
}

- (instancetype)initWithConfig:(SINServiceConfig *)config {
  SINSParameterCondition(config);
  SINSParameterCondition(config.applicationKey);
  SINSParameterCondition(config.environmentHost);
  // applicationSecret is optional

  self = [super init];
  if (self) {
    _config = config;
    _persistence = [[SINSServicePersistence alloc] initWithConfig:_config];

    {
      _clientsObserver = [[SINSClientsObserver alloc] init];
      __weak id weakSelf = self;
      _clientsObserver.didStartHandler = ^(id<SINClient> client) {
        [weakSelf onClientDidStart:client];
      };
      _clientsObserver.willTerminateHandler = ^(id<SINClient> client) {
        [weakSelf onClientWillTerminate:client];
      };
      _clientsObserver.didFailHandler = ^(id<SINClient> client, NSError *error) {
        [weakSelf onClientDidFail:client error:error];
      };
    }

    if (_config.managedPushNotifications) {
      _push = [Sinch managedPushWithAPSEnvironment:_config.apsEnvironment];
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(onDidReceiveRemoteNotification:)
                                                   name:SINApplicationDidReceiveRemoteNotification
                                                 object:_push];
      [_push setDesiredPushTypeAutomatically];
    }

    _callClient = [[SINSLazyCallClient alloc] init];
    _messageClient = [[SINSLazyMessageClient alloc] init];
    _audioController = [[SINSLazyAudioController alloc] init];
  }
  return self;
}

- (void)dealloc {
  if (_push) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SINApplicationDidReceiveRemoteNotification
                                                  object:_push];
  }
}

- (id<SINManagedPush>)push {
  if (!_config.managedPushNotifications) {
    [NSException raise:NSInternalInconsistencyException
                format:@"enableManagedPushNotifications: was not configured for %@",
                       NSStringFromClass([SINServiceConfig class])];
  }
  return _push;
}

- (NSString *)userId {
  if (self.client) {
    return [self.client userId];
  }
  return nil;
}

- (void)logInUserWithId:(NSString *)userId {
  SINSParameterCondition(userId);

  if (self.client) {
    if ([[self.client userId] isEqualToString:userId]) {
      return;
    }
    [self.client terminate];
    self.client = nil;
  }

  SINServiceConfig *cfg = [self config];
  NSParameterAssert(cfg);

  id<SINClient> client;
  if ([cfg.applicationSecret length] > 0) {
    client = [Sinch clientWithApplicationKey:cfg.applicationKey
                           applicationSecret:cfg.applicationSecret
                             environmentHost:cfg.environmentHost
                                      userId:userId];

  } else {
    client = [Sinch clientWithApplicationKey:cfg.applicationKey environmentHost:cfg.environmentHost userId:userId];
  }

  client.delegate = self;

  [client setSupportMessaging:cfg.messaging];
  [client setSupportCalling:cfg.calling];

  if (cfg.managedPushNotifications) {
    [client enableManagedPushNotifications];
  }

  [client setSupportActiveConnectionInBackground:cfg.activeConnectionInBackground];

  self.client = client;

  // Assign proxees before calling -[SINClient start], so that delegates are properly transferred / assigned
  // if needed throughout the startup phase. E.g. if a client is started as a consequence of receiving a
  // incoming remote push notification, the call client delegate must be assigned to be able to schedule a local
  // notification for the call.
  [_callClient setProxee:[client callClient]];
  [_audioController setProxee:[client audioController]];
  [_messageClient setProxee:[client messageClient]];

  [self.client start];

  if (cfg.activeConnection) {
    [self.client startListeningOnActiveConnection];
  }
}

- (void)logInLastKnownUser {
  if ([[self lastKnownUserId] length]) {
    [self logInLastKnownUserIfPossible];
  } else {
    NSError *error = SINServiceCreateError(SINServiceErrorUserIdNotAvailable, @"No persisted UserId is available");
    [self notifyError:error];
  }
}

- (NSString *)lastKnownUserId {
  NSString *userId = [self.persistence objectForKey:SINServiceUserIdKey];
  if ([userId length]) {
    return userId;
  }
  return nil;
}

- (void)logInLastKnownUserIfPossible {
  NSString *userId = [self lastKnownUserId];
  if ([userId length]) {
    [self logInUserWithId:userId];
  }
}

- (void)logOutUser {
  [self.persistence removeObjectForKey:SINServiceUserIdKey];

  if (self.client) {
    [self.client unregisterPushNotificationDeviceToken];
    [self.client terminateGracefully];
    self.client = nil;
  }
}

- (void)setDelegate:(id<SINServiceDelegate>)delegate {
  _delegate = delegate;
  _delegateRespondsToLogCallback =
      [_delegate respondsToSelector:@selector(service:logMessage:area:severity:timestamp:)];
}

#pragma mark - SINClientDelegate

- (void)clientDidStart:(id<SINClient>)client {
  // noop, we use onClientDidStart: via NSNotification
}

- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error {
  // noop, we use onClientDidFail:error: via NSNotification
}

- (void)client:(id<SINClient>)client requiresRegistrationCredentials:(id<SINClientRegistration>)registrationCallback {
  if ([self.delegate respondsToSelector:@selector(service:requiresRegistrationCredentials:)]) {
    [self.delegate service:self requiresRegistrationCredentials:registrationCallback];
  } else {
    NSLog(@"WARNING: no delegate assigned to handle SINClient authorization");
  }
}

- (void)client:(id<SINClient>)client
    logMessage:(NSString *)message
          area:(NSString *)area
      severity:(SINLogSeverity)severity
     timestamp:(NSDate *)timestamp {
  if (_delegateRespondsToLogCallback) {
    [self.delegate service:self logMessage:message area:area severity:severity timestamp:timestamp];
  }
}

#pragma mark - SINClientsObserver handlers

- (void)onClientDidStart:(id<SINClient>)client {
  if (client == self.client) {
    // persist last known successfully logged in user
    [self.persistence setObject:client.userId forKey:SINServiceUserIdKey];
  }
}

- (void)onClientWillTerminate:(id<SINClient>)client {
  if (client == self.client) {
    [_callClient setProxee:nil];
    [_messageClient setProxee:nil];
    [_audioController setProxee:nil];
  }
}

- (void)onClientDidFail:(id<SINClient>)client error:(NSError *)error {
  if (client == self.client) {
    [self notifyError:error];
  }
}

- (void)notifyError:(NSError *)error {
  NSParameterAssert(error);
  if ([self.delegate respondsToSelector:@selector(service:didFailWithError:)]) {
    [self.delegate service:self didFailWithError:error];
  }
}

#pragma mark -

- (void)onDidReceiveRemoteNotification:(NSNotification *)note {
  NSAssert([note object] == _push, @"%@", @"");
  if ([note object] == _push) {
    NSDictionary *dictionaryPayload = note.userInfo[SINRemoteNotificationKey];
    if ([dictionaryPayload sin_isSinchPushPayload]) {
      if (!self.client) {
        [self logInLastKnownUserIfPossible];
      }

      // If we had a client since before, or if logInLastKnownUserIfPossible succeded
      if (self.client) {
        id result = [self.client relayRemotePushNotification:dictionaryPayload];
        if (result && [self.delegate respondsToSelector:@selector(service:didReceiveNotification:)]) {
          [self.delegate service:self didReceiveNotification:result];
        }
      }
    } /* else: was not a Sinch push at all? */
  }
}

@end
