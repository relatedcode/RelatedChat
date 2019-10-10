/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

@protocol SINCallDelegate;
@protocol SINCallDetails;
@protocol SINPushPair;

#pragma mark - Call State

typedef NS_ENUM(NSInteger, SINCallState) {
  SINCallStateInitiating = 0,
  SINCallStateProgressing,  // Only applicable to outgoing calls
  SINCallStateEstablished,
  SINCallStateEnded
};

#pragma mark - Call Direction

typedef NS_ENUM(NSInteger, SINCallDirection) { SINCallDirectionIncoming = 0, SINCallDirectionOutgoing };

#pragma mark - SINCall

/**
 * The SINCall represents a call.
 */
@protocol SINCall <NSObject>

/**
 * The object that acts as the delegate of the call.
 *
 * The delegate object handles call state change events and must
 * adopt the SINCallDelegate protocol.
 *
 * @see SINCallDelegate
 */
@property (nonatomic, weak) id<SINCallDelegate> delegate;

/** String that is used as an identifier for this particular call. */
@property (nonatomic, readonly, copy) NSString *callId;

/** The id of the remote participant in the call. */
@property (nonatomic, readonly, copy) NSString *remoteUserId;

/**
 * Metadata about a call, such as start time.
 *
 * When a call has ended, the details object contains information
 * about the reason the call ended and error information if the
 * call ended unexpectedly.
 *
 * @see SINCallDetails
 */
@property (nonatomic, readonly, strong) id<SINCallDetails> details;

/**
 * The state the call is currently in. It may be one of the following:
 *
 *  - `SINCallStateInitiating`
 *  - `SINCallStateProgressing`
 *  - `SINCallStateEstablished`
 *  - `SINCallStateEnded`
 *
 * Initially, the call will be in the `SINCallStateInitiating` state.
 */
@property (nonatomic, readonly, assign) SINCallState state;

/**
 * The direction of the call. It may be one of the following:
 *
 *  - `SINCallDirectionIncoming`
 *  - `SINCallDirectionOutgoing`
 *
 */
@property (nonatomic, readonly, assign) SINCallDirection direction;

/**
 * Call headers.
 *
 * Any application-defined call meta-data can be passed via headers.
 *
 * E.g. a human-readable "display name / username" can be convenient
 * to send as an application-defined header.
 *
 * IMPORTANT: If a call is initially received via remote push
 * notifications, headers may not be immediately available due to
 * push payload size limitations (especially pre- iOS 8).
 * If it's not immediately available, it will be available after the
 * event callbacks -[SINCallDelegate callDidProgress:] or
 * -[SINCallDelegate callDidEstablish:] .
 *
 **/
@property (nonatomic, readonly) NSDictionary *headers;

/**
 * The user data property may be used to associate an arbitrary
 * contextual object with a particular instance of a call.
 */
@property (nonatomic, strong) id userInfo;

/** Answer an incoming call. */
- (void)answer;

/**
 * Ends the call, regardless of what state it is in. If the call is
 * an incoming call that has not yet been answered, the call will
 * be reported as denied to the caller.
 */
- (void)hangup;

/**
 * Sends a DTMF tone for tone dialing. (Only applicable for calls terminated
 * to PSTN (Publicly Switched Telephone Network)).
 *
 * @param key DTMF key must be in [0-9, #, *, A-D].
 *
 * @exception NSInvalidArgumentException Throws exception if key does not have a
 *                                       valid mapping to a DTMF tone.
 *
 */
- (void)sendDTMF:(NSString *)key;

/**
 * Pause video track for this call
 *
 */
- (void)pauseVideo;

/**
 * Start video track for this call
 *
 */
- (void)resumeVideo;


@end

#pragma mark - SINCallDelegate

/**
 * The delegate of a SINCall object must adopt the SINCallDelegate
 * protocol. The required methods handle call state changes.
 *
 * ### Call State Progression
 *
 * For a complete outgoing call, the delegate methods will be called
 * in the following order:
 *
 *  - `callDidProgress:`
 *  - `callDidEstablish:`
 *  - `callDidEnd:`
 *
 * For a complete incoming call, the delegate methods will be called
 * in the following order, after the client delegate method
 * `[SINClientDelegate client:didReceiveIncomingCall:]` has been called:
 *
 *  - `callDidEstablish:`
 *  - `callDidEnd:`
 */
@protocol SINCallDelegate <NSObject>

@optional

/**
 * Tells the delegate that the call ended.
 *
 * The call has entered the `SINCallStateEnded` state.
 *
 * @param call The call that ended.
 *
 * @see SINCall
 */
- (void)callDidEnd:(id<SINCall>)call;

/**
 * Tells the delegate that the outgoing call is progressing and a progress tone can be played.
 *
 * The call has entered the `SINCallStateProgressing` state.
 *
 * @param call The outgoing call to the client on the other end.
 *
 * @see SINCall
 */
- (void)callDidProgress:(id<SINCall>)call;

/**
 * Tells the delegate that the call was established.
 *
 * The call has entered the `SINCallStateEstablished` state.
 *
 * @param call The call that was established.
 *
 * @see SINCall
 */
- (void)callDidEstablish:(id<SINCall>)call;

/**
 * Tells the delegate that the callee device can't be reached directly,
 * and it is required to wake up the callee's application with an
 * Apple Push Notification (APN).
 *
 * @param call The call that requires the delegate to send an
 *             Apple Push Notification (APN) to the callee device.
 *
 * @param pushPairs  Array of SINPushPair. Each pair identififies a certain
 *                   device that should be requested to be woken up via
 *                   Apple Push Notification.
 *
 *                   The push data entries are equal to what the receiver's
 *                   application passed to the method
 *                   -[SINClient registerPushNotificationData:].
 *
 * @see SINPushPair
 * @see SINCall
 * @see SINClient
 */
- (void)call:(id<SINCall>)call shouldSendPushNotifications:(NSArray *)pushPairs;

/**
 * Tells the delegate that a video track has been added to the call.
 * (A delegate can use `SINVideoController` to manage rendering views.)
 *
 * @see SINVideoController
 */
- (void)callDidAddVideoTrack:(id<SINCall>)call;
- (void)callDidPauseVideoTrack:(id<SINCall>)call;
- (void)callDidResumeVideoTrack:(id<SINCall>)call;


@end

