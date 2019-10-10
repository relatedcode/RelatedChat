/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

#import <Sinch/SINLogSeverity.h>
#import <Sinch/SINAPSEnvironment.h>
#import <Sinch/SINForwardDeclarations.h>

#pragma mark - SINServiceConfig

// SINServiceConfig is used when creating a SINService
//
// A config will by default have the following features and behaviour specified:
//
// - Calling is enabled
// - Instant Messaging is enabled
// - Active Connection is enabled (but not when the application moves to background)
//
// It is recommended to enable support for remote push notifications by using
// -[SINServiceConfig pushNotificationsWithEnvironment:].
//

@interface SINServiceConfig : NSObject

- (instancetype)initWithApplicationKey:(NSString *)applicationKey
                     applicationSecret:(NSString *)applicationSecret
                       environmentHost:(NSString *)environmentHost;

- (instancetype)initWithApplicationKey:(NSString *)applicationKey environmentHost:(NSString *)environmentHost;

// Enable use of Apple Remote Push Notifications
// (this is a chainable mutator, returns self)
- (instancetype)pushNotificationsWithEnvironment:(SINAPSEnvironment)apsEnvironment;

// Disable Calling Feature
// (this is a chainable mutator, returns self)
- (instancetype)disableCalling;

// Disable Instant Messaging
// (this is a chainable mutator, returns self)
- (instancetype)disableMessaging;

// Maps to -[SINClient setSupportActiveConnectionInBackground:]
- (instancetype)enableActiveConnectionInBackground;

// The SINService will by default invoke -[SINClient startListeningOnActiveConnection]
// when starting a Sinch client. This behaviour can be disabled via this method.
// If active connection is disabled, remote push notifications should be used (see
// -[SINServiceConfig pushNotificationsWithEnvironment:]).
- (instancetype)disableActiveConnection;

@end

#pragma mark - SINService

@protocol SINServiceDelegate;

@protocol SINService <NSObject>

@property (nonatomic, readwrite, weak) id<SINServiceDelegate> delegate;

- (NSString *)userId;  // currently active userId. may be nil

- (void)logInUserWithId:(NSString *)userId;
- (void)logOutUser;

- (id<SINCallClient>)callClient;

- (id<SINMessageClient>)messageClient;

- (id<SINClient>)client;

- (id<SINManagedPush>)push;

- (id<SINAudioController>)audioController;

@end

#pragma mark - SINServiceDelegate

@protocol SINServiceDelegate <NSObject>

@optional

- (void)service:(id<SINService>)service didFailWithError:(NSError *)error;

- (void)service:(id<SINService>)service
     logMessage:(NSString *)message
           area:(NSString *)area
       severity:(SINLogSeverity)severity
      timestamp:(NSDate *)timestamp;

- (void)service:(id<SINService>)service requiresRegistrationCredentials:(id<SINClientRegistration>)registrationCallback;

// Delegate is notified of the notification result _after_ it's been relayed to the underlying SINClient.
- (void)service:(id<SINService>)service didReceiveNotification:(id<SINNotificationResult>)notificationResult;

@end
