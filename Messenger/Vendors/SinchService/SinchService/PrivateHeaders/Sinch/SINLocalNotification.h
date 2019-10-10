/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>
#import <Sinch/SINExport.h>

/**
 * SINLocalNotification can be used to specify presentation data for a local
 * push that is to be used for an incoming call.
 *
 * The properties are mirroring the properties available for UILocalNotification.
 *
 * @see UILocalNotification
 */
SIN_EXPORT
@interface SINLocalNotification : NSObject

/**
 * The message displayed in the notification alert.
 *
 * Assign a string or, preferably, a localized-string key
 * (using NSLocalizedString) as the value of the message. If the value of this
 * property is non-nil, an alert is displayed. The default value is nil
 * (no alert).
 */
@property (nonatomic, copy) NSString *alertBody;

/**
 * A Boolean value that controls whether the notification shows or hides the
 * alert action.
 *
 * Assign NO to this property to hide the alert button or slider.
 * (This effect requires alertBody to be non-nil.) The default value is YES.
 */
@property (nonatomic) BOOL hasAction;

/**
 * The title of the action button or slider.
 *
 * Assign a string or, preferably, a localized-string key
 * (using NSLocalizedString) as the value. The alert action is the title of the
 * right button of the alert or the value of the unlock slider, where the value
 * replaces “unlock” in “slide to unlock”. If you specify nil, and alertBody is
 * non-nil, “View” (localized to the preferred language) is used as the default
 * value.
 */
@property (nonatomic, copy) NSString *alertAction;

/**
 * Identifies the image used as the launch image when the user taps (or slides)
 * the action button (or slider).
 *
 * The string is a filename of an image file in the application bundle.
 * This image is a launching image specified for a given notification;
 * when the user taps the action button (for example, “View”) or moves the
 * action slider, the image is used in place of the default launching image.
 * If the value of this property is nil (the default), the system either uses
 * the previous snapshot, uses the image identified by the UILaunchImageFile key
 * in the application’s Info.plist file, or falls back to Default.png.
 */
@property (nonatomic, copy) NSString *alertLaunchImage;

/**
 * The name of the file containing the sound to play when an alert is displayed.
 *
 * For this property, specify the filename (including extension) of a sound
 * resource in the application’s main bundle or
 * UILocalNotificationDefaultSoundName to request the default system sound.
 * When the system displays an alert for a local notification or badges an
 * application icon, it plays this sound.
 * The default value is nil (no sound).
 * Sounds that last longer than 30 seconds are not supported. If you specify a
 * file with a sound that plays over 30 seconds, the default sound is played
 * instead.
 *
 */
@property (nonatomic, copy) NSString *soundName;

/**
 * The number to display as the application’s icon badge.
 *
 * The default value is 0, which means "no change.” The application should use
 * this property’s value to increment the current icon badge number, if any.
 */
@property (nonatomic) NSInteger applicationIconBadgeNumber;

/**
 * Category of the local notification, as passed to
 * +[UIUserNotificationSettings settingsForUserNotificationTypes:userNotificationActionSettings:]
 * The value of this property is nil by default.
 * @see UILocalNotification.category
 */
@property (nonatomic, copy) NSString *category NS_AVAILABLE_IOS(8_0);

@end
