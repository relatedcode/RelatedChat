/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#ifndef SIN_APS_ENVIRONMENT_H
#define SIN_APS_ENVIRONMENT_H

/**
 * SINAPSEnvironment is used to declare to which Apple Push Notification Service environment a device token is bound to.
 *
 * SINAPSEnvironment is used with `-[SINClient registerPushNotificationDeviceToken:type:apsEnvironment:]` or
 * `SINManagedPush`.
 *
 * ### Example
 *
 * An application which is codesigned and provisioned with a "Development" Provisioning Profile
 * will be tied to the APNS Development Gateway (gateway.sandbox.push.apple.com)
 *
 * An application which is codesigned and provisioned with a "Distribution" Provisioning Profile
 * will be tied to the APNS Production Gateway (gateway.push.apple.com)
 *
 * The macro `SINAPSEnvironmentAutomatic` can be used to specify SINAPSEnvironment based on the type of build.
 * (Because it is a pre-processor macro, it will be based on build configuration (Debug/Release) of the application
 * which is consuming the Sinch SDK.)
 *
 * See Apple documentation for further details:
 * https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html
 */

typedef NS_ENUM(NSInteger, SINAPSEnvironment) {
  SINAPSEnvironmentDevelopment = 1,  // APNS Development environment
  SINAPSEnvironmentProduction = 2    // APNS Production environment
};

// The following defines SINAPSEnvironmentAutomatic based on presence
// of the pre-processing macros NDEBUG and/or DEBUG.
// If NDEBUG is defined it will have precedence over DEBUG.

#ifndef SINAPSEnvironmentAutomatic
#ifdef NDEBUG
#define SINAPSEnvironmentAutomatic SINAPSEnvironmentProduction
#else
#ifdef DEBUG
#define SINAPSEnvironmentAutomatic SINAPSEnvironmentDevelopment
#else
#define SINAPSEnvironmentAutomatic SINAPSEnvironmentProduction
#endif  // ifdef DEBUG
#endif  // ifdef NDEBUG
#endif  // ifndef SINAPSEnvironmentAutomatic

#endif  // SIN_APS_ENVIRONMENT_H
