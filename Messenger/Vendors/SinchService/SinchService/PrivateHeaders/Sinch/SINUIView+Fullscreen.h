/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <UIKit/UIKit.h>

/**
 * SINUIViewFullscreenAdditions are helper methods (implemented as Objective-C
 * category methods) to make views go to full screen mode (and back to it's
 * previous state)
 */

@interface UIView (SINUIViewFullscreenAdditions)

/**
 * @return YES if view is in full screen mode or is about to be (in animation transition).
 */
- (BOOL)sin_isFullscreen;

/**
 * Make view go into full screen mode.
 *
 * The view will be moved out of it's current place in the view hierarchy and will
 * be added as a subview directly in the main UIWindow.
 */
- (void)sin_enableFullscreen:(BOOL)animated;

/**
 * Make view go back to it's original state before full screen mode was enabled.
 *
 * The view will be moved back to it's original superview, and it's original frame will be restored.
 */
- (void)sin_disableFullscreen:(BOOL)animated;

@end
