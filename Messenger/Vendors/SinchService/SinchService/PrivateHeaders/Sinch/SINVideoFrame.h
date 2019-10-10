/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <CoreVideo/CVPixelBuffer.h>

/**
 * The object for representing a video frame in YUV I420 format.
 */
@protocol SINVideoFrame <NSObject>

/** The frame width. */
@property (readonly) int width;

/** The frame height. */
@property (readonly) int height;

/**
 * A method for creating a CVPixelBuffer from the video frame.
 * The caller of this method takes the ownership of the CVPixelBuffer,
 * and is responsible for releasing it by calling CVPixelBufferRelease().
 */
- (CVPixelBufferRef)createCVPixelBuffer;

/**
 * A method for releasing the frame data.
 * Has to be called after the frame callback is done processing the frame.
 */
- (void)releaseFrame;

@end
