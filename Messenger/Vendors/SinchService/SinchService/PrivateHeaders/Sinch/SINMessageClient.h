/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

@protocol SINMessageClientDelegate;
@protocol SINMessage;
@class SINOutgoingMessage;
@protocol SINMessageDeliveryInfo;
@protocol SINMessageFailureInfo;

/**
 *
 * SINMessageClient provides the entry point to the messaging functionality of the Sinch SDK.
 * A SINMessageClient can be acquired via SINClient.
 *
 * ### Example
 *
 * 	[sinchClient setSupportMessaging:YES];
 * 	[sinchClient start];
 * 	...
 *
 * 	// Get the message client from the sinchClient
 * 	SINMessageClient messageClient = [sinchClient messageClient];
 *
 * 	// Assign a delegate for instant messages events
 * 	messageClient.delegate = ...
 *
 * 	//Send a message
 * 	SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipient:@"<recipient user id> text:@"Hi there!"];
 * 	[messageClient sendMessage:message];
 *
 */
@protocol SINMessageClient <NSObject>

/**
 * Assigns a delegate to the Message Client.
 *
 * Applications implementing instant messaging should assign a delegate
 * adopting the SINMessageClientDelegate protocol. The delegate will be
 * notified when messages arrive and receive message status updates.
 *
 * @see SINMessageClientDelegate
 */

@property (nonatomic, weak) id<SINMessageClientDelegate> delegate;

/**
 * Sends an outgoing message.
 *
 * Message progress is communicated via the SINMessageClientDelegate.
 *
 * *Note*: Do not send the same SINOutgoingMessage more than once.
 *
 * @see SINMessageClientDelegate
 * @see +[SINOutgoingMessage messageWithRecipient:text:]
 *
 * @param message The message to be sent.
 *
 * @exception NSInvalidArgumentException Throws exception if message is invalid,
 *            e.g. if no recipient is set.
 *
 */
- (void)sendMessage:(SINOutgoingMessage *)message;

@end

/**
 *
 * The message client delegate by which message events are communicated.
 *
 **/
@protocol SINMessageClientDelegate <NSObject>

/**
 * Tells the delegate that a message has been received.
 *
 * @param messageClient The message client that is informing the delegate.
 *
 * @param message The incoming message.
 *
 * @see SINMessageClient, SINMessage
 **/
- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message;

/**
 * Tells the delegate that a message for a specific recipient has been sent by the local user.
 *
 * This method is called when a message is sent from
 * the local message client (i.e. -[SINMessageClient sendMessage:]).
 * This callback is triggered on all devices on which the local user is logged in.
 *
 * @param message Message that was sent.
 *
 * @param recipientId Recipient of the message
 *
 * @see SINMessageClient, SINMessage
 */
- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId;

/**
 * Tells the delegate that a message has been delivered (to a particular
 * recipient).
 *
 * @param info Info identifying the message that was delivered, and to whom.
 *
 **/
- (void)messageDelivered:(id<SINMessageDeliveryInfo>)info;

/**
 * Tells the delegate that the message client failed to send a message.
 *
 * *Note*: Do not attempt to re-send the SINMessage received, instead,
 * create a new SINOutgoingMessage and send that.
 *
 * @param messageFailureInfo SINMessageFailureInfo object,
 *                            identifying the message and for which recipient
 *                            sending the message failed.
 *
 * @param message The message that could not be delivered.
 **/
- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)messageFailureInfo;

@optional

/**
 * Tells the delegate that the receiver's device can't be reached directly,
 * and it is required to wake up the receiver's application with a push
 * notification.
 *
 * @param message    The message for which pushing is required.
 *
 * @param pushPairs  Array of SINPushPair. Each pair identififies a certain
 *                   device that should be requested to be woken up via
 *                   Apple Push Notification.
 *
 *                   The push data entries are equal to what the receiver's
 *                   application passed to the method
 *                   -[SINClient registerPushNotificationData:] method.
 *
 * @see SINPushPair
 *
 **/
- (void)message:(id<SINMessage>)message shouldSendPushNotifications:(NSArray *)pushPairs;

@end
