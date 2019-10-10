/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Sinch/SINExport.h>

/**
 * SINOutgoingMessage should be used to create outgoing instant-messages.
 */
SIN_EXPORT
@interface SINOutgoingMessage : NSObject

/** String that is used as an identifier for this particular message. */
@property (nonatomic, readonly) NSString *messageId;

/** Array of ids of the recipients of the message. */
@property (nonatomic, readonly) NSArray *recipientIds;

/** Message body text */
@property (nonatomic, readonly) NSString *text;

/** Message headers */
@property (nonatomic, readonly) NSDictionary *headers;

/**
 * Creates a new message with the specified recipient and message body.
 * @exception NSInvalidArgumentException Throws exception if message is invalid,
 *            e.g. if no recipient is set or text is nil.
 *
 * @param recipientId The indended recipient's id.
 * @param text Message text
 */
+ (SINOutgoingMessage *)messageWithRecipient:(NSString *)recipientId text:(NSString *)text;

/**
 * Creates a new message with the specified recipients and message body.
 * @exception NSInvalidArgumentException Throws exception if message is invalid,
 *            e.g. if no recipient is set or text is nil.
 *
 * @param recipientIds The indended recipients' ids.
 * @param text Message text
 */
+ (SINOutgoingMessage *)messageWithRecipients:(NSArray *)recipientIds text:(NSString *)text;

/**
 *  Creates a SINOutgoingMessage from a SINMessage.
 *
 *  @param message The original message
 *
 *  @return A new sendable message. This message will have the same contents
 *  as the previous message but with a new id.
 *
 */
+ (SINOutgoingMessage *)messageWithMessage:(id<SINMessage>)message;

/**
 * Add a message header
 *
 * The total size of header keys + values (when encoded with
 * NSUTF8StringEncoding) must not exceed 1024 bytes.
 *
 * @param value Header value
 * @param key Header key
 */
- (void)addHeaderWithValue:(NSString *)value key:(NSString *)key;

@end
