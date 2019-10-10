/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Call End Cause

typedef NS_ENUM(NSInteger, SINCallEndCause) {
  SINCallEndCauseNone = 0,
  SINCallEndCauseTimeout = 1,
  SINCallEndCauseDenied = 2,
  SINCallEndCauseNoAnswer = 3,
  SINCallEndCauseError = 4,
  SINCallEndCauseHungUp = 5,
  SINCallEndCauseCanceled = 6,
  SINCallEndCauseOtherDeviceAnswered = 7
};

#pragma mark - SINCallDetails

/**
 * The SINCallDetails holds metadata about a call (SINCall).
 */
@protocol SINCallDetails <NSObject>

/**
 * The start time of the call.
 *
 * Before the call has started, the value of the startedTime property is `nil`.
 */
@property (nonatomic, readonly, strong) NSDate *startedTime;

/**
 * The time at which the call was established, if it reached established state.
 *
 * Before the call has reached established state, the value of the establishedTime property is `nil`.
 */
@property (nonatomic, readonly, strong) NSDate *establishedTime;

/**
 * The end time of the call.
 *
 * Before the call has ended, the value of the endedTime property is `nil`.
 */
@property (nonatomic, readonly, strong) NSDate *endedTime;

/**
 * Holds the cause of why a call ended, after it has ended. It may be one
 * of the following:
 *
 *  - `SINCallEndCauseNone`
 *  - `SINCallEndCauseTimeout`
 *  - `SINCallEndCauseDenied`
 *  - `SINCallEndCauseNoAnswer`
 *  - `SINCallEndCauseError`
 *  - `SINCallEndCauseHungUp`
 *  - `SINCallEndCauseCanceled`
 *  - `SINCallEndCauseOtherDeviceAnswered`
 *
 * If the call has not ended yet, the value is `SINCallEndCauseNone`.
 */
@property (nonatomic, readonly) SINCallEndCause endCause;

/**
 * If the end cause is error, then this property contains an error object
 * that describes the error.
 *
 * If the call has not ended yet or if the end cause is not an error,
 * the value of this property is `nil`.
 */
@property (nonatomic, readonly, strong) NSError *error;

/**
 * The application state when the call was received.
 */
@property (nonatomic, readonly) UIApplicationState applicationStateWhenReceived;

/**
 * Hint that indicates if video is offered in the call.
 */
@property (nonatomic, readonly, getter=isVideoOffered) BOOL videoOffered;

@end
