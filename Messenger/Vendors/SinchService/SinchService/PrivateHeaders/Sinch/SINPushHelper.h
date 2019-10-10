/*
 * Copyright (c) 2018 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Sinch/SINExport.h>
#import <Sinch/SINForwardDeclarations.h>

SIN_EXPORT
@interface SINPushHelper : NSObject

/**
 * Method used to parse a remote notification dictionary if using -[SINClient enableManagedPushNotifications];
 *
 * @return Value indicating initial inspection of push notification.
 *
 * @param userInfo Remote notification payload which was transferred with an Apple Push Notification.
 *                 and received via -[UIApplicationDelegate application:didReceiveRemoteNotification:].
 *
 * @see SINNotificationResult
 */
+ (id<SINNotificationResult>)queryPushNotificationPayload:(NSDictionary *)userInfo;

@end
