/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

@protocol SINAudioControllerDelegate;

#pragma mark - SINAudioController

/**
 * The SINAudioController provides methods for controlling audio related
 * functionality, e.g. enabling the speaker, muting the microphone, and
 * playing sound files.
 *
 * ### Playing Sound Files
 *
 * The audio controller provides a convenience method
 * (startPlayingSoundFile:loop:) for playing sounds
 * that are related to a call, such as ringtones and busy tones.
 *
 * ### Example
 *
 * 	id<SINAudioController> audio = [client audioController];
 * 	NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ringtone"
 * 	                                                      ofType:@"wav"];
 *
 * 	[audio startPlayingSoundFile:soundPath loop:YES];
 *
 *
 * Applications that prefer to use their own code for playing sounds are free
 * to do so, but they should follow a few guidelines related to audio
 * session categories and audio session activation/deactivation (see
 * Sinch SDK User Guide for details).
 *
 * #### Sound File Format
 *
 *  The sound file must be a mono (1 channel), 16-bit, uncompressed (PCM)
 * .wav file with a sample rate of 8kHz, 16kHz, or 32kHz.
 */
@protocol SINAudioController <NSObject>

/**
 * The object that acts as the delegate of the audio controller.
 *
 * The delegate object handles audio related state changes.
 *
 * @see SINAudioControllerDelegate
 */
@property (nonatomic, weak) id<SINAudioControllerDelegate> delegate;

/**
 * Mute the microphone.
 */
- (void)mute;

/**
 * Unmute the microphone.
 */
- (void)unmute;

/**
 * Route the call audio through the speaker.
 *
 * Changing the audio route for a call is only possible when the call has
 * been established.
 *
 * @see SINCallStateEstablished
 * @see -[SINCallDelegate callDidEstablish:]
 *
 */
- (void)enableSpeaker;

/**
 * Route the call audio through the handset earpiece.
 *
 * Changing the audio route for a call is only possible when the call has
 * been established.
 *
 * @see SINCallStateEstablished
 * @see -[SINCallDelegate callDidEstablish:]
 *
 */
- (void)disableSpeaker;

/**
 * Play a sound file, for the purpose of playing ringtones, etc.
 *
 * This is a simple convenience method for playing sounds associated with
 * a call, such as ringtones. It can only play one sound file at a time.
 *
 * For advanced audio, apps that use the SDK should implement their own
 * methods for playing sounds.
 *
 * Regardless of whether a sound is looping or not, a corresponding call
 * to the stopPlayingSoundFile method must be done at some point after each
 * invocation of this method.
 *
 * The sound file must be a mono (1 channel), 16-bit, uncompressed (PCM)
 * .wav file with a sample rate of 8kHz, 16kHz, or 32kHz.
 *
 * @param path Full path for the sound file to play.
 *
 * @param loop Specifies whether the sound should loop or not.
 *
 * @exception NSInvalidArgumentException Throws exception if no file exists
 *                                       at the given path.
 *
 */
- (void)startPlayingSoundFile:(NSString *)path loop:(BOOL)loop;

/**
 * Stop playing the sound file.
 */
- (void)stopPlayingSoundFile;

@end

/**
 * The delegate of a SINAudioController object must adopt the
 * SINAudioControllerDelegate protocol. The methods handle audio
 * related state changes.
 */
@protocol SINAudioControllerDelegate <NSObject>
@optional

/**
 * Notifies the delegate that the microphone was muted.
 *
 * @param audioController The audio controller associated with this delegate.
 *
 * @see SINAudioController
 */
- (void)audioControllerMuted:(id<SINAudioController>)audioController;

/**
 * Notifies the delegate that the microphone was unmuted.
 *
 * @param audioController The audio controller associated with this delegate.
 *
 * @see SINAudioController
 */
- (void)audioControllerUnmuted:(id<SINAudioController>)audioController;

/**
 * Notifies the delegate that the speaker was enabled.
 *
 * @param audioController The audio controller associated with this delegate.
 *
 * @see SINAudioController
 */
- (void)audioControllerSpeakerEnabled:(id<SINAudioController>)audioController;

/**
 * Notifies the delegate that the speaker was disabled.
 *
 * @param audioController The audio controller associated with this delegate.
 *
 * @see SINAudioController
 */
- (void)audioControllerSpeakerDisabled:(id<SINAudioController>)audioController;

@end
