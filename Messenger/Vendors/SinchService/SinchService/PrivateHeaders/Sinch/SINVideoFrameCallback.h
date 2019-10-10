/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

@protocol SINVideoFrame;

/**
 * The callback object that will process frames from a remote stream.
 */
@protocol SINVideoFrameCallback <NSObject>

/**
 * This method is called when a new frame is received.
 *
 * IMPORTANT: The implementor of this protocol is responsible for explicitly
 * releasing the frame by calling -[SINVideoFrame releaseFrame].
 *
 * @param frame The video frame.
 * @param callId The identifier of the call that received a frame.
 *
 * @see @SINVideoFrame
 */
- (void)onFrame:(id<SINVideoFrame>)videoFrame callId:(NSString*)callId;

@end

