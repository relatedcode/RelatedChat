/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

/**
 * The SINPushPair contains push related information.
 */
@protocol SINPushPair

/**
 * The push data to use when forwarding the push payload to a device. The push
 * data is equal to the data passed to -[SINClient registerPushNotificationData:].
 */
@property (nonatomic, retain) NSData* pushData;

/**
 * The push payload contains call/instant-message information encoded by
 * the Sinch SDK. The payload should considered opaque to the
 * application developer, and should be delivered to the callee/ recipient of
 * an instant-message via appropriate push service, e.g. Apple Push Notification
 * Service (APNS) or Google Cloud Messaging (GCM). Once received on the
 * destination device, it should be passed to the
 * Sinch via the method -[SINClient relayRemotePushNotificationPayload:].
 */
@property (nonatomic, retain) NSString* pushPayload;

@end
