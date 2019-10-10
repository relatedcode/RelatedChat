/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

#import <Sinch/SINForwardDeclarations.h>
#import <Sinch/SINExport.h>
#import <Sinch/SINAPSEnvironment.h>
#import <Sinch/SINLogSeverity.h>

SIN_EXPORT SIN_EXTERN NSString *const SINClientDidStartNotification;
SIN_EXPORT SIN_EXTERN NSString *const SINClientDidFailNotification;
SIN_EXPORT SIN_EXTERN NSString *const SINClientWillTerminateNotification;

#pragma mark - Log Severity

#pragma mark - SINClient

/**
 * The SINClient is the Sinch SDK entry point.
 *
 * It provides access to the feature classes in the Sinch SDK:
 * SINMessageClient, SINCallClient and SINAudioController.
 * It is also used to configure the user's and device's capabilities.
 *
 * ### User Identification
 *
 * The user IDs that are used to identify users application specific.
 * If the app already has a scheme for user IDs (email addresses,
 * phone numbers, customer numbers, etc.), the same ID could be used
 * when configuring the SINClient.
 *
 * ### Example
 *
 * 	// Instantiate a client object using the client factory.
 * 	id<SINClient> sinchClient = [Sinch clientWithApplicationKey:@"<APPKEY>"
 * 	                                          applicationSecret:@"<APPSECRET>"
 * 	                                            environmentHost:@"clientapi.sinch.com"
 * 	                                                     userId:@"<USERID>"];
 *
 * 	// Specify the client capabilities. At least one of the messaging or calling capabilities should be enabled.
 * 	[sinchClient setSupportCalling:YES];
 * 	[sinchClient setSupportMessaging:YES];
 * 	[sinchClient setSupportPushNotifications:YES]; // (optional)
 *
 * 	// Set your delegate object
 * 	sinchClient.delegate = ... ;
 *
 * 	// Start the client
 * 	[sinchClient start];
 *
 * 	// Start listening for incoming events (calls and messages).
 * 	[sinchClient startListeningOnActiveConnection];
 *
 * 	// Use the SINCallClient to place and receive calls
 * 	// Use the SINMessageClient  to send and receive messages
 *
 * 	// Stop listening for incoming events (calls and messages).
 * 	[sinchClient stopListeningOnActiveConnection];
 *
 * 	// Terminate the client when the calling and messaging functionalities are no longer needed.
 * 	[sinchClient terminate];
 */
@protocol SINClient <NSObject>

/**
 * The object that acts as the delegate of the receiving client.
 *
 * The delegate object handles call state change events and must
 * adopt the SINClientDelegate protocol.
 *
 * @see SINClientDelegate
 */
@property (nonatomic, weak) id<SINClientDelegate> delegate;

/**
 * ID of the local user
 */
@property (nonatomic, readonly, copy) NSString *userId;

/**
 *
 * Specify whether this device should support making and receiving calls.
 * Default is NO.
 *
 * Method should be called before calling -[SINClient start].
 *
 * @param supported Enable or disable support making and receiving calls.
 * @see SINCallClient
 *
 */
- (void)setSupportCalling:(BOOL)supported;

/**
 *
 * Specify the data protection type (NSFileProtectionType) for the files created and used by the Sinch SDK.
 * If not set specifically, the files will inherit the data protection level defined in your Application.
 *
 * Method should be called before calling -[SINClient start].
 *
 * @param type the data protection type applied to the files created by the Sinch SDK.
 *
 */
- (void)setDataProtectionType:(NSFileProtectionType)type;

/**
 * Specify whether this application should support sending and receiving instant messages.
 * Default is NO.
 *
 * Method should be called before calling -[SINClient start].
 *
 * @param supported Enable or disable support for instant messaging.
 *
 * @see SINMessageClient
 *
 */
- (void)setSupportMessaging:(BOOL)supported;

/**
 * Specify whether this device should receive incoming calls via push
 * notifications.
 *
 * Method should be called before calling -[SINClient start].
 *
 * @param supported Enable or disable support for push notifications.
 *
 * @see -[SINClient registerPushNotificationData:]
 * @see -[SINClient unregisterPushNotificationData];
 * @see -[SINClient relayRemotePushNotificationPayload:];
 *
 */
- (void)setSupportPushNotifications:(BOOL)supported;

/**
 * Specify that the Sinch SDK and platform should take care of
 * sending the push notification to the other device via the appropriate
 * push notification gateway (i.e. Apple Push Notification Service for iOS devices,
 * and Google Cloud Messaging (GCM) for Android devices).
 *
 * (This require that you have uploaded your Apple Push Notification
 * Certificate(s) on the Sinch website)
 *
 * This method will internally also invoke -[SINClient setSupportPushNotifications:YES]
 *
 * Method should be called before calling -[SINClient start].
 *
 * @see -[SINClient registerPushNotificationDeviceToken:type:apsEnvironment:]
 * @see -[SINClient unregisterPushNotificationDeviceToken];
 * @see -[SINClient relayRemotePushNotificationPayload:];
 *
 */
- (void)enableManagedPushNotifications;

/**
 * [DEPRECATED] Specify whether to keep the active connection open if the application
 * leaves foreground.
 *
 * If specified to be supported, the active connection which is used for
 * receiving incoming calls will be kept open even if the application leaves
 * foreground. Enabling this also requires that 'voip' is specified for
 * UIBackgroundModes in the application's Info.plist.
 *
 * If specified to not be supported, the application will not be running in the
 * background, and the active connection which is used for receiving incoming
 * calls will be closed once the application leaves foreground.
 * (Though it will be re-opened once the application returns to foreground).
 * If not supported, the application will be required to rely on push
 * notifications to receive incoming calls if the application leaves foreground.
 *
 * If specified to be supported, the client's delegate is required to implement
 * additional parts of the SINClientDelegate protocol. It is required to
 * implement -[SINClientDelegate client:localNotificationForIncomingCall:]
 *
 * This method should be called before calling -[SINClient start].
 *
 * @param supported Specifies whether the active connection should be kept open
 *                  even if the application leaves foreground.
 *
 * @exception NSInternalInconsistencyException Throws exception if called after
 *                                             client is started.
 *
 */
- (void)setSupportActiveConnectionInBackground:(BOOL)supported NS_DEPRECATED_IOS(4_0, 9_0, "Please use PushKit and SINManagedPush");

/**
 * Start client to enable the calling functionality.
 *
 * The client delegate should be set before calling the start method to
 * guarantee that delegate callbacks are received as expected.
 *
 */
- (void)start;

/**
 * Terminate client when the calling functionality is no longer needed.
 *
 * It is generally recommended to initiate the Sinch client, start it, but not
 * terminate it, during the lifetime of the running application. If incoming calls
 * are not desired for a limited period of time or similar scenarios, it is
 * instead recommended to only stop listening for incoming calls via the method
 * (-[SINClient stopListeningOnActiveConnection]).
 * This is simply because initializing and starting the client is relatively
 * resource intensive both in terms of CPU, as well as there is potentially
 * network requests involved in stopping and re-starting the client.
 *
 * If desired to dispose the client, it is required to explicitly invoke terminate
 * (or terminateGracefully) to relinquish certain resources.
 * This method should always be called before the application code releases its
 * last reference to the client.
 *
 */
- (void)terminate;

/**
* Terminates the client, while still leaving it some time to finish up currently
* pending tasks, for example finishing pending HTTP requests.
*
* See -[SINClient terminate].
*/
- (void)terminateGracefully;

/**
 * THIS METHOD IS DEPRECATED. See -[SINClient terminate]
 */
- (void)stop;

/**
 * Check whether client is successfully started.
 *
 * @return A boolean value indicating whether the client has successfully
 *         started and is ready to perform calling functionality.
 */
- (BOOL)isStarted;

/**
 * This will establish an active keep-alive connection as a signaling channel
 * for receiving incoming calls.
 *
 * Note that the active connection will only be kept open while the application
 * is running in foreground. To support receiving calls while the application is
 * in the background (or not running), please use push notifications.
 */
- (void)startListeningOnActiveConnection;

/**
 * This will close the connection that is kept alive and used as signaling
 * channel for receiving incoming calls. This method should be used when the
 * application no longer intends to utilize the long-lived connection for
 * receiving incoming calls.
 *
 * If the intention is to completely turn off incoming calls and the application
 * is also using push notifications as a method of receiving
 * incoming calls, then the application should also unregister previously
 * registered push notification data via the method
 * -[SINClient unregisterPushNotificationData].
 *
 */
- (void)stopListeningOnActiveConnection;

/**
 * Method used to forward the Sinch-specific payload extracted from an incoming
 * Apple Push Notification.
 *
 * @return Value indicating initial inspection of push notification payload.
 *
 * @param payload Sinch-specific payload which was transferred with an
 *        Apple Push Notification.
 *
 * @see SINNotificationResult
 */
- (id<SINNotificationResult>)relayRemotePushNotificationPayload:(NSString *)payload;

/**
 * Method used to forward a remote notification dictionary if using -[SINClient enableManagedPushNotifications];
 *
 * @return Value indicating initial inspection of push notification.
 *
 * @param userInfo Remote notification payload which was transferred with an Apple Push Notification.
 *                 and received via -[UIApplicationDelegate application:didReceiveRemoteNotification:].
 *
 * @see SINNotificationResult
 */
- (id<SINNotificationResult>)relayRemotePushNotification:(NSDictionary *)userInfo;

/**
 * Method used to handle a local notification which has been scheduled and
 * taken action upon by the application user.
 *
 * @return Value indicating outcome of the attempt to handle the notification.
 *
 * @param notification UILocalNotification
 *
 * @exception NSInternalInconsistencyException Throws exception if called before
 *            client startup has completed.
 *            A case when the client might not be started yet is if the
 *            application user takes action on an local notification that is not
 *            relevant any more. E.g. the user ignored the notification when it
 *            was first presented, then quit the app, and the notification was
 *            left in Notification Center and was taken action upon at a later
 *            time.
 *            Applications should relay all local notifications where sin_isSinchNotification
 *            is True.
 *
 *
 *            -[SINClient isStarted] may be used to guard against calling this
 *            method at inappropriate times.
 *
 * @see -[SINClient isStarted]
 * @see SINNotificationResult
 *
 */
- (id<SINNotificationResult>)relayLocalNotification:(UILocalNotification *)notification;

/**
 * Register device-specific data that can be used to identify this device
 * and tie it to an Apple Push Notification device token.
 *
 * @param pushNotificationData Device-specific data that can be used to
 *                             tie a device to a specific Apple Push
 *                             Notification device token
 *
 * The `pushNotificationData` is what will be passed back in
 * -[SINCallDelegate call:shouldSendPushNotifications:]
 * in the caller's application, unless the application on the destination device
 * (the device on which this method is called) is not running in the background,
 * and is required to woken up it via a Apple Push Notification.
 *
 * See [UIApplication registerForRemoteNotificationTypes:] on how to obtain
 * the current device token.
 *
 * @see SINCallDelegate
 */
- (void)registerPushNotificationData:(NSData *)pushNotificationData;

/**
 * Unregister previously registered device-specific data that is used to
 * identify this device and tie it to an Apple Push Notification device token.
 *
 * If it is unwanted that the user receives further remote push notifications
 * for Sinch calls, this method should be used to unregister the push data.
 */
- (void)unregisterPushNotificationData;

/**
 * Register push notification device token for using "Sinch Managed Push Notifications".
 * The preferred way of enabling push notifications is to use `SINManagedPush` which
 * will automatically register the device token with the client, but this method can
 * also be used directly.
 *
 * @param deviceToken A token that identifies the device to APNs.
 * @param pushType SINPushType NSString constant, i.e. SINPushTypeVoIP or SINPushTypeRemote
 * @param apsEnvironment Specification of which Apple Push Notification Service environment
 *                       the device token is bound to.
 *
 * @see SINAPSEnvironment
 * @see SINPushTypeVoIP
 * @see SINPushTypeRemote
 */
- (void)registerPushNotificationDeviceToken:(NSData *)deviceToken
                                       type:(NSString *)pushType
                             apsEnvironment:(SINAPSEnvironment)apsEnvironment;

/**
 * Unregister push notification device token when using "Sinch Managed Push Notifications"
 * Example if the user log out, the device token should be unregistered.
 */
- (void)unregisterPushNotificationDeviceToken;

/**
 * Specify a display name to be used when the Sinch client sends a push notification on
 * behalf of the local user (e.g. for an outgoing call).
 * This will only be used when using -[SINClient enableManagedPushNotifications].
 *
 * Display name is included in a push notification on a best-effort basis. For example, if the
 * target device has very limited push payload size constraints (e.g iOS 7 can only handle
 * 255 byte push notification payload), then the display name may not be included.
 *
 * @param displayName display name may at most be 255 bytes (UTF-8 encoded) long.
 */
- (void)setPushNotificationDisplayName:(NSString *)displayName;

/**
 *
 * Returns the call client object for placing and receiving calls.
 *
 * @see - [SINClient setSupportCalling:]
 *
 */
- (id<SINCallClient>)callClient;

/**
 *
 * Returns the message client object for sending messages and adding
 * delegates for message events.
 *
 * @see - [SINClient setSupportMessaging:]
 *
 */
- (id<SINMessageClient>)messageClient;

/**
 * Retrieve the interface for the audio controller, which provides access
 * to various audio related functionality, such as muting the microphone,
 * enabling the speaker, and playing ring tones.
 */
- (id<SINAudioController>)audioController;

/**
 * Retrieve the interface for the video controller, which provides
 * access to video related functionality.
 */
- (id<SINVideoController>)videoController;

@end

/**
 * The delegate of a SINClient object must adopt the SINClientDelegate
 * protocol. The required methods handle client state changes and the
 * optional log method allows the delegate to log messages from the
 * underlying calling functionality.
 *
 * When an incoming call has been received,
 * [SINClientDelegate client:didReceiveIncomingCall:] is called.
 * The delegate of the incoming call object should be set at this time.
 */
@protocol SINClientDelegate <NSObject>

/**
 * Tells the delegate that the client started the calling functionality.
 *
 * @param client The client informing the delegate that the calling
 *               functionality started successfully.
 *
 * @see SINClient
 */
- (void)clientDidStart:(id<SINClient>)client;

/**
 * Tells the delegate that a client failure occurred.
 *
 * @param client The client informing the delegate that it
 *               failed to start or start listening.
 *
 * @param error Error object that describes the problem.
 *
 * @see SINClient
 */
- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error;

@optional

/**
 * DEPRECATED. Do not use.
 */
- (void)clientDidStop:(id<SINClient>)client;

/**
 * Tells the delegate that it is required to provide additional registration
 * credentials.
 *
 * @param client The client informing the delegate that it requires
 *               additional registration details.
 *
 * @param registrationCallback The callback object that is to be called
 *               when registration credentials have been fetched.
 *
 * @see SINClientRegistration
 * @see SINClient
 */
- (void)client:(id<SINClient>)client requiresRegistrationCredentials:(id<SINClientRegistration>)registrationCallback;

/**
 * The delegate object can choose to subscribe to log messages from
 * the underlying calling functionality by implementing this method.
 *
 * The easiest way to log the messages is to simply write them to
 * the device console using NSLog:
 *
 *     `NSLog(@"[%@] %u %@", timestamp, severity, message);`
 *
 * *Caution:* Only log messages with severity level `SINLogSeverityWarn`
 * or higher to the console in release builds, to avoid flooding the
 * device console with debugging messages.
 *
 * @param client The client that the log messages are coming from.
 *
 * @param message The message that is being logged.
 *
 * @param area The area that the log message relates to.
 *
 * @param severity The severity level of the log message. It may be one of
 *                 the following:
 *
 *                  - `SINLogSeverityTrace`
 *                  - `SINLogSeverityInfo`
 *                  - `SINLogSeverityWarn`
 *                  - `SINLogSeverityCritical`
 *
 * @param timestamp The time when the message was logged.
 *
 * @see SINClient
 */
- (void)client:(id<SINClient>)client
    logMessage:(NSString *)message
          area:(NSString *)area
      severity:(SINLogSeverity)severity
     timestamp:(NSDate *)timestamp;

@end
