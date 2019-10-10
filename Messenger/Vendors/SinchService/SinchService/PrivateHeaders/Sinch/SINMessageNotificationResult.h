/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

/**
 * SINMessageNotificationResult is used to indicate the outcome of invoking
 * the method -[SINClient relayRemotePushNotificationPayload:] in the case that
 * the notification payload represents an instant message.
 *
 * SINMessageNotificationResult contains a `messageId`, and `senderId`.
 * The `messageId` can for example be very useful when the application, upon
 * receiving the notification, needs to direct the user to to a view that
 * displays/highlights this particular message.
 *
 */

@protocol SINMessageNotificationResult <NSObject>

/** The message's id */
@property (nonatomic, readonly, copy) NSString *messageId;

/** The sender's user id */
@property (nonatomic, readonly, copy) NSString *senderId;

@end
