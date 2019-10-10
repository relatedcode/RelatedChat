/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

/**
 * SINMessage represents an instant message.
 *
 * (Also see SINOutgoingMessage.h)
 *
 **/
@protocol SINMessage <NSObject>

/** String that is used as an identifier for this particular message. */
@property (nonatomic, readonly) NSString* messageId;

/** Array of ids of the recipients of the message. */
@property (nonatomic, readonly) NSArray* recipientIds;

/** The id of the sender of the message. */
@property (nonatomic, readonly) NSString* senderId;

/** Message body text */
@property (nonatomic, readonly) NSString* text;

/**
 * Message headers
 *
 * Any application-defined message meta-data
 * can be passed via headers.
 *
 * E.g. a human-readable "display name / username"
 * can be convenient to send as an application-defined
 * header.
 *
 **/
@property (nonatomic, readonly) NSDictionary* headers;

/**
 * Message timestamp
 *
 * Server-side-based timestamp for the message.
 * May be nil for message which is created locally, i.e. an outgoing message.
 */
@property (nonatomic, readonly) NSDate* timestamp;

@end
