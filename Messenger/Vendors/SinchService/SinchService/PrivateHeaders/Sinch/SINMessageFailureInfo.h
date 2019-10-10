/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

/**
 * SINMessageFailureInfo contains additional information pertaining to
 * failing to send a message.
 * @see -[SINMessageClientDelegate messageFailed:info:].
 */

@protocol SINMessageFailureInfo <NSObject>

/** The message's identifier */
@property (nonatomic, readonly, copy) NSString *messageId;

/** The identifier of the recipient */
@property (nonatomic, readonly, copy) NSString *recipientId;

/** The error reason */
@property (nonatomic, readonly, copy) NSError *error;

@end
