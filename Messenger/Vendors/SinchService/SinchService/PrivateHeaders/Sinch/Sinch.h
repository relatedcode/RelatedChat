/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

#import "SINExport.h"

#import "SINClient.h"
#import "SINClientRegistration.h"

#import "SINCallClient.h"
#import "SINCall.h"
#import "SINCallDetails.h"

#import "SINMessageClient.h"
#import "SINMessage.h"
#import "SINOutgoingMessage.h"
#import "SINMessageDeliveryInfo.h"
#import "SINMessageFailureInfo.h"

#import "SINAudioController.h"

#import "SINVideoController.h"

#import "SINPushPair.h"
#import "SINManagedPush.h"
#import "SINAPSEnvironment.h"
#import "SINPushHelper.h"

#import "SINLocalNotification.h"
#import "SINUILocalNotification+Sinch.h"

#import "SINNotificationResult.h"
#import "SINCallNotificationResult.h"
#import "SINMessageNotificationResult.h"

#import "SINLogSeverity.h"
#import "SINError.h"

/**
 * The Sinch class is used to instantiate a SINClient.
 *
 * This is the starting point for an app that wishes to use the Sinch SDK.
 *
 * To construct a SINClient, the required configuration parameters are:
 *
 *  - Application Key
 *  - Environment host (Production or Sandbox)
 *  - UserID
 *
 * It is optional to specify:
 *
 *  - Application Secret (see the specific factory methods and the User Guide
 *    for details on why and how to use the secret).
 *
 *  - CLI (Calling-Line Identifier / Caller-ID) that will be used for calls
 *    terminated to PSTN (Publicly Switched Telephone Network).
 */
SIN_EXPORT
@interface Sinch : NSObject

#pragma mark - Basic factory methods

/**
 * Instantiate a new client.
 *
 * If the client is initiated with an application key, but no application
 * secret, starting the client the first time will require additional
 * authorization credentials as part of registering the user.
 * It will therefore be required of the SINClientDelegate to implement
 * -[SINClientDelegate client:requiresRegistrationCredentials:].
 *
 * @return The newly instantiated client.
 *
 * @param applicationKey Application key identifying the application.
 *
 * @param environmentHost Host for base URL for the Sinch API environment
 *                        to be used. E.g. 'sandbox.sinch.com'
 *
 *
 * @param userId ID of the local user
 *
 * @see SINClient
 * @see SINClientRegistration
 */

+ (id<SINClient>)clientWithApplicationKey:(NSString *)applicationKey
                          environmentHost:(NSString *)environmentHost
                                   userId:(NSString *)userId;

/**
 * Instantiate a new client.
 *
 * @return The newly instantiated client.
 *
 * This method should be used if user-registration and authorization with Sinch
 * is to be handled completely by the app (without additional involvement
 * of a backend-service providing additional credentials to the application.)
 *
 * @param applicationKey Application key identifying the application.
 *
 * @param applicationSecret Application secret bound to application key.
 *
 * @param environmentHost Host for base URL for the Sinch API environment
 *                        to be used. E.g 'sandbox.sinch.com'
 *
 *
 * @param userId ID of the local user
 *
 * @see SINClient
 */

+ (id<SINClient>)clientWithApplicationKey:(NSString *)applicationKey
                        applicationSecret:(NSString *)applicationSecret
                          environmentHost:(NSString *)environmentHost
                                   userId:(NSString *)userId;

#pragma mark - Factory methods with support for CLI / PSTN

/**
 * Instantiate a new client with a CLI (may be used for PSTN-terminated calls).
 *
 * If the client is initiated with an application key, but no application
 * secret, starting the client the first time will require additional
 * authorization credentials as part of registering the user.
 * It will therefore be required of the SINClientDelegate to implement
 * -[SINClientDelegate client:requiresRegistrationCredentials:].
 *
 * @return The newly instantiated client.
 *
 * @param applicationKey Application key identifying the application.
 *
 * @param environmentHost Host for base URL for the Sinch API environment
 *                        to be used. E.g. 'sandbox.sinch.com'
 *
 *
 * @param userId ID of the local user
 *
 * @param cli Caller-ID when terminating calls to PSTN. Must be a valid phone
 *            number.
 *
 * @see SINClient
 * @see SINClientRegistration
 */

+ (id<SINClient>)clientWithApplicationKey:(NSString *)applicationKey
                          environmentHost:(NSString *)environmentHost
                                   userId:(NSString *)userId
                                      cli:(NSString *)cli;

/**
 * Instantiate a new client with a CLI (may be used for PSTN-terminated calls).
 *
 * @return The newly instantiated client.
 *
 * This method should be used if user-registration and authorization with Sinch
 * is to be handled completely by the app (without additional involvement
 * of a backend-service providing additional credentials to the application.)
 *
 * @param applicationKey Application key identifying the application.
 *
 * @param applicationSecret Application secret bound to application key.
 *
 * @param environmentHost Host for base URL for the Sinch API environment
 *                        to be used. E.g 'sandbox.sinch.com'
 *
 *
 * @param userId ID of the local user
 *
 * @param cli Caller-ID when terminating calls to PSTN. Must be a valid phone
 *            number.
 *
 * @see SINClient
 */

+ (id<SINClient>)clientWithApplicationKey:(NSString *)applicationKey
                        applicationSecret:(NSString *)applicationSecret
                          environmentHost:(NSString *)environmentHost
                                   userId:(NSString *)userId
                                      cli:(NSString *)cli;

/**
 * Instantiate a new `SINManagedPush` instance to enable Push Notifications
 * managed by the Sinch SDK and platform. When using managed push notifications,
 * push notifications will be sent by the Sinch platform provided that Apple
 * Push Notification Certificates for your application have been uploaded to Sinch.
 *
 * @param apsEnvironment Specification of which Apple Push Notification Service environment
 *                       the application is bound to (via code signing and Provisioning Profile).
 *
 * @see SINAPSEnvironment
 */
+ (id<SINManagedPush>)managedPushWithAPSEnvironment:(SINAPSEnvironment)apsEnvironment;

/**
 * Returns the Sinch SDK version.
 */
+ (NSString *)version;

@end
