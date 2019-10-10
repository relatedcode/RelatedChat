/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * SINLocalNotificationSinchAdditions is a set of category methods for
 * the UILocalNotification class.
 *
 */

@interface UILocalNotification (SINLocalNotificationSinchAdditions)

/**
 * Indicates that the UILocalNotification was created by the Sinch SDK
 */
- (BOOL)sin_isSinchNotification;

/**
 * The UILocalNotification represents an incoming call
 */
- (BOOL)sin_isIncomingCall;

/**
 * The UILocalNotification represents a missed call
 */
- (BOOL)sin_isMissedCall;

@end
