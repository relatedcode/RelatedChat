/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Sinch/SINExport.h>
#import <Sinch/SINForwardDeclarations.h>

@protocol SINVideoController <NSObject>

/**
 * Indicates the capture device position (front-facing or back-facing
 * camera) currently in use. This property may be set to to change
 * which capture device should be used.
 */
@property (nonatomic, assign, readwrite) AVCaptureDevicePosition captureDevicePosition;

/**
 * Automatically set/unset UIApplication.idleTimerDisabled when video capturing is started / stopped.
 * Default is YES.
 */
@property (nonatomic, assign, readwrite) BOOL disableIdleTimerOnCapturing;

/**
 * View into which the remote peer video stream is rendered.
 *
 * Use -[UIView contentMode] to control how the video frame is rendered.
 * (Note that only UIViewContentModeScaleAspectFit and UIViewContentModeScaleAspectFill will be respected)
 *
 * Use -[UIView backgroundColor] to specify color for potential "empty" regions
 * when UIViewContentModeScaleAspectFit is used.
 *
 * @see SINUIViewFullscreenAdditions (SINUIView+Fullscreen.h) for helpers to toggle full screen.
 */
- (UIView*)remoteView;

/**
 * View into which the locally captured video stream is rendered.
 *
 * Use -[UIView contentMode] to control how the video frame is rendered.
 * (Note that only UIViewContentModeScaleAspectFit and UIViewContentModeScaleAspectFill will be respected)
 *
 * Use -[UIView backgroundColor] to specify color for potential "empty" regions
 * when UIViewContentModeScaleAspectFit is used.
 *
 * @see SINUIViewFullscreenAdditions (SINUIView+Fullscreen.h) for helpers to toggle full screen.
 */
- (UIView*)localView;

/**
 * Set a callback for listening to video frames from a remote stream.
 *
 * @param callback The callback object that will receive frames.
 *
 * @see SINVideoFrameCallback
 */
- (void)setVideoFrameCallback:(id<SINVideoFrameCallback>)callback;

/**
 * Set a callback for listening to video frames captured from the local camera.
 *
 * @param callback The callback object that will receive frames.
 *
 * @see SINLocalVideoFrameCallback
 */

- (void)setLocalVideoFrameCallback:(id<SINLocalVideoFrameCallback>)callback;

@end

/**
 * If input position is front-facing camera, returns back-facing camera.
 * If input position is back-facing camera, returns front-facing camera.
 * If input is AVCaptureDevicePositionUnspecified, returns input.
 */
SIN_EXPORT AVCaptureDevicePosition SINToggleCaptureDevicePosition(AVCaptureDevicePosition position);

/**
 * Convert a SINVideoFrame to an UIImage.
 */
SIN_EXPORT UIImage* SINUIImageFromVideoFrame(id<SINVideoFrame> videoFrame);
