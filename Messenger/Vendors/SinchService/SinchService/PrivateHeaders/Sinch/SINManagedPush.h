/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Sinch/SINExport.h>
#import <Sinch/SINAPSEnvironment.h>

SIN_EXPORT SIN_EXTERN NSString *const SINPushTypeVoIP NS_AVAILABLE_IOS(8_0);
SIN_EXPORT SIN_EXTERN NSString *const SINPushTypeRemote NS_AVAILABLE_IOS(6_0);

// SINApplicationDidReceiveRemoteNotification is emitted for both VoIP and Remote Push Notifications.
// Also emitted for remote notifications received at application launched (i.e. via
// UIApplicationDidFinishLaunchingNotification with UIApplicationLaunchOptionsRemoteNotificationKey)
// SINApplicationDidReceiveRemoteNotification provides a unified way of listening for incoming remote notifications.
SIN_EXPORT SIN_EXTERN NSString *const SINApplicationDidReceiveRemoteNotification;

// SINRemoteNotificationKey
// userInfo contains NSDictionary with payload
SIN_EXPORT SIN_EXTERN NSString *const SINRemoteNotificationKey;

// SINPushTypeKey
// userInfo contains this key with value SINPushTypeVoIP or SINPushTypeRemote
SIN_EXPORT SIN_EXTERN NSString *const SINPushTypeKey;

/**
 * SINManagedPush is a helper class to manage push notification credentials both
 * for regular Remote Push Notifications and VoIP Push Notifications (which is
 * available since iOS 8).
 *
 * SINManagedPush acts as a facade for registering for device tokens for both
 * types of notifications, and can also automatically register any received push
 * credentials to any active SINClient.
 *
 * SINManagedPush simplifies scenarios such as when receiving a device token
 * occur before creating a SINClient. In such a case, SINManagedPush can
 * automatically register the device token when the SINClient is created and
 * started.
 *
 * ### Example
 *
 * 	-(BOOL)application:(UIApplication *)application
 * 	  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 * 	    self.push = [Sinch managedPushWithAPSEnvironment:SINAPSEnvironmentAutomatic]
 * 	    [self.push setDesiredPushTypeAutomatically];
 * 	    [self.push registerUserNotificationSettings];
 * 	}
 *
 */

@protocol SINManagedPushDelegate;

@protocol SINManagedPush <NSObject>

@property (nonatomic, readwrite, weak) id<SINManagedPushDelegate> delegate;

/**
 * Specify what user notification types should be used for remote push notifications.
 *
 * @property      userNotificationTypes
 *
 * Defaults to UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge
 *
 * userNotificationTypes should be set before invoking -[SINManagedPush setDesiredPushType:] or
 * -[SINManagedPush setDesiredPushTypeAutomatically].
 */
@property (nonatomic, readwrite, assign) UIUserNotificationType userNotificationTypes;

/**
 *  Requests registration of either VoIP remote notifications or regular remote
 *  notifications (similar to PushKit's -[PKPushRegistry setDesiredPushTypes:]).
 *
 * @param pushType Desired SINPushType NSString constant, e.g. SINPushTypeVoIP or SINPushTypeRemote
 */
- (void)setDesiredPushType:(NSString *)pushType;

/**
 *  Set desired push type based on runtime detection of iOS version and whether
 *  PushKit is linked or not.  This method will invoke `-[self setDesiredPushType:SINPushTypeVoIP]`
 *  if PushKit is linked, else `-[self setDesiredPushType:SINPushTypeRemote]`.
 */
- (void)setDesiredPushTypeAutomatically;

/**
 *  Similar to -[UIApplication registerUserNotificationSettings:], this will
 *  register user notification settings based on `-[SINManagedPush
 *  userNotificationTypes]`.
 *
 *  On iOS 8 or higher it will invoke `-[UIApplication registerUserNotificationSettings:]` and
 *  on iOS 7 or lower it will invoke `-[UIApplication registerForRemoteNotificationTypes:]`.
 */
- (void)registerUserNotificationSettings;

/**
 * Specify a display name to be used when Sinch sends a push notification on
 * behalf of the local user (e.g. for an outgoing call). This method will
 * automatically invoke `-[SINClient setPushNotificationDisplayName:]` when a
 * new Sinch client is started.
 *
 * @param displayName Display name that will be injected into remote push notification
 *                    alert message.
 *
 * Display name will be injected into the localization string SIN_INCOMING_CALL_DISPLAY_NAME.
 * It will also be passed along in Google Cloud Messaging push notifications if a remote
 * user's device is an Android device.
 *
 * @see SINClient
 */
- (void)setDisplayName:(NSString *)displayName;

#pragma mark - Methods to be delegated from UIApplicationDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end

@protocol SINManagedPushDelegate <NSObject>

/**
 * Tells the delegate that a remote notification was received. The remote notification may be either a VoIP remote
 * push notification, or a regular push remote notification.
 *
 * @param managedPush managed push instance that received the push notification
 * @param payload The dictionary payload that the remote push notification carried.
 * @param pushType SINPushTypeVoIP or SINPushTypeRemote
 */
- (void)managedPush:(id<SINManagedPush>)managedPush
    didReceiveIncomingPushWithPayload:(NSDictionary *)payload
                              forType:(NSString *)pushType;
@end

@interface NSDictionary (SINRemoteNotificationAdditions)

/**
 * Category method to determine whether a remote push notification dictionary payload
 * is carrying a Sinch payload.
 */
- (BOOL)sin_isSinchPushPayload;

@end
