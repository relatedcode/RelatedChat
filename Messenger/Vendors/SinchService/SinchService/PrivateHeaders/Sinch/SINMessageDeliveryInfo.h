/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

/**
 * SINMessageDeliveryInfo contains additional information pertaining
 * to a delivered message.
 *
 * @see -[SINMessageClientDelegate messageDelivered:].
 */

@protocol SINMessageDeliveryInfo <NSObject>

/** The message's identifier */
@property (nonatomic, readonly, copy) NSString *messageId;

/** The identifier of the recipient */
@property (nonatomic, readonly, copy) NSString *recipientId;

/** Server-side-based timestamp */
@property (nonatomic, readonly, copy) NSDate *timestamp;

@end
