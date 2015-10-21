//
//  IQAudioRecorderController.m
// https://github.com/hackiftekhar/IQAudioRecorderController
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "IQAudioRecorderController.h"

#import "SCSiriWaveformView.h"

#import <AVFoundation/AVFoundation.h>

/************************************/

@implementation NSString (TimeString)

+(NSString*)timeStringForTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        return  [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    }
}

@end

@interface IQInternalAudioRecorderController : UIViewController <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    //Recording...
    AVAudioRecorder *_audioRecorder;
    SCSiriWaveformView *musicFlowView;
    NSString *_recordingFilePath;
    BOOL _isRecording;
    CADisplayLink *meterUpdateDisplayLink;
    
    //Playing
    AVAudioPlayer *_audioPlayer;
    BOOL _wasPlaying;
    UIView *_viewPlayerDuration;
    UISlider *_playerSlider;
    UILabel *_labelCurrentTime;
    UILabel *_labelRemainingTime;
    CADisplayLink *playProgressDisplayLink;

    //Navigation Bar
    NSString *_navigationTitle;
    UIBarButtonItem *_cancelButton;
    UIBarButtonItem *_doneButton;
    
    //Toolbar
    UIBarButtonItem *_flexItem1;
    UIBarButtonItem *_flexItem2;
    UIBarButtonItem *_playButton;
    UIBarButtonItem *_pauseButton;
    UIBarButtonItem *_recordButton;
    UIBarButtonItem *_trashButton;
    
    //Private variables
    NSString *_oldSessionCategory;
}

@property (nonatomic, weak) id<IQAudioRecorderControllerDelegate> delegate;
@property (nonatomic, assign) BOOL shouldShowRemainingTime;

@property (nonatomic, weak) UIColor *normalTintColor;
@property (nonatomic, weak) UIColor *recordingTintColor;
@property (nonatomic, weak) UIColor *playingTintColor;

@end

/************************************/

@implementation IQAudioRecorderController
{
    IQInternalAudioRecorderController *_internalController;
}
@synthesize delegate = _delegate;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _internalController = [[IQInternalAudioRecorderController alloc] init];
    _internalController.delegate = self.delegate;
    _internalController.normalTintColor = self.normalTintColor;
    _internalController.recordingTintColor = self.recordingTintColor;
    _internalController.playingTintColor = self.playingTintColor;
    
    self.viewControllers = @[_internalController];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.translucent = YES;
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.toolbarHidden = NO;
    self.toolbar.tintColor = self.navigationBar.tintColor;
    self.toolbar.translucent = self.navigationBar.translucent;
    self.toolbar.barStyle = self.navigationBar.barStyle;
}

-(void)setDelegate:(id<IQAudioRecorderControllerDelegate,UINavigationControllerDelegate>)delegate
{
    _delegate = delegate;
    _internalController.delegate = delegate;
}

@end

/************************************/

@implementation IQInternalAudioRecorderController

-(void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor darkGrayColor];

    musicFlowView = [[SCSiriWaveformView alloc] initWithFrame:view.bounds];
    musicFlowView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:musicFlowView];
    self.view = view;

    NSLayoutConstraint *constraintRatio = [NSLayoutConstraint constraintWithItem:musicFlowView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:musicFlowView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:musicFlowView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:musicFlowView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:musicFlowView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [musicFlowView addConstraint:constraintRatio];
    [view addConstraints:@[constraintWidth,constraintCenterX,constraintCenterY]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _navigationTitle = @"Audio Recorder";
    _normalTintColor = (self.normalTintColor ? self.normalTintColor : [UIColor whiteColor]);
    _recordingTintColor = (self.recordingTintColor ? self.recordingTintColor : [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0]);
    _playingTintColor = (self.playingTintColor ? self.playingTintColor : [UIColor colorWithRed:255.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0]);
    
    self.view.tintColor = self.normalTintColor;
    musicFlowView.backgroundColor = [self.view backgroundColor];
//    musicFlowView.idleAmplitude = 0;

    //Unique recording URL
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    _recordingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",fileName]];

    {
        _flexItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _flexItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        _recordButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"audio_record"] style:UIBarButtonItemStylePlain target:self action:@selector(recordingButtonAction:)];
        _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction:)];
        _pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseAction:)];
        _trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
        [self setToolbarItems:@[_playButton,_flexItem1, _recordButton,_flexItem2, _trashButton] animated:NO];

        _playButton.enabled = NO;
        _trashButton.enabled = NO;
    }
    
    // Define the recorder setting
    {
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordingFilePath] settings:recordSetting error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        
        [musicFlowView setPrimaryWaveLineWidth:3.0f];
        [musicFlowView setSecondaryWaveLineWidth:1.0];
    }

    //Navigation Bar Settings
    {
        self.navigationItem.title = @"Audio Recorder";
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        self.navigationItem.leftBarButtonItem = _cancelButton;
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    }
    
    //Player Duration View
    {
        _viewPlayerDuration = [[UIView alloc] init];
        _viewPlayerDuration.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _viewPlayerDuration.backgroundColor = [UIColor clearColor];

        _labelCurrentTime = [[UILabel alloc] init];
        _labelCurrentTime.text = [NSString timeStringForTimeInterval:0];
        _labelCurrentTime.font = [UIFont boldSystemFontOfSize:14.0];
        _labelCurrentTime.textColor = _normalTintColor;
        _labelCurrentTime.translatesAutoresizingMaskIntoConstraints = NO;

        _playerSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        _playerSlider.minimumTrackTintColor = _playingTintColor;
        _playerSlider.value = 0;
        [_playerSlider addTarget:self action:@selector(sliderStart:) forControlEvents:UIControlEventTouchDown];
        [_playerSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
        [_playerSlider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_playerSlider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
        _playerSlider.translatesAutoresizingMaskIntoConstraints = NO;

        _labelRemainingTime = [[UILabel alloc] init];
        _labelCurrentTime.text = [NSString timeStringForTimeInterval:0];
        _labelRemainingTime.userInteractionEnabled = YES;
        [_labelRemainingTime addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)]];
        _labelRemainingTime.font = _labelCurrentTime.font;
        _labelRemainingTime.textColor = _labelCurrentTime.textColor;
        _labelRemainingTime.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_viewPlayerDuration addSubview:_labelCurrentTime];
        [_viewPlayerDuration addSubview:_playerSlider];
        [_viewPlayerDuration addSubview:_labelRemainingTime];
        
        NSLayoutConstraint *constraintCurrentTimeLeading = [NSLayoutConstraint constraintWithItem:_labelCurrentTime attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_viewPlayerDuration attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        NSLayoutConstraint *constraintCurrentTimeTrailing = [NSLayoutConstraint constraintWithItem:_playerSlider attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_labelCurrentTime attribute:NSLayoutAttributeTrailing multiplier:1 constant:10];
        NSLayoutConstraint *constraintRemainingTimeLeading = [NSLayoutConstraint constraintWithItem:_labelRemainingTime attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_playerSlider attribute:NSLayoutAttributeTrailing multiplier:1 constant:10];
        NSLayoutConstraint *constraintRemainingTimeTrailing = [NSLayoutConstraint constraintWithItem:_viewPlayerDuration attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_labelRemainingTime attribute:NSLayoutAttributeTrailing multiplier:1 constant:10];
        
        NSLayoutConstraint *constraintCurrentTimeCenter = [NSLayoutConstraint constraintWithItem:_labelCurrentTime attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_viewPlayerDuration attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *constraintSliderCenter = [NSLayoutConstraint constraintWithItem:_playerSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_viewPlayerDuration attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *constraintRemainingTimeCenter = [NSLayoutConstraint constraintWithItem:_labelRemainingTime attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_viewPlayerDuration attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        [_viewPlayerDuration addConstraints:@[constraintCurrentTimeLeading,constraintCurrentTimeTrailing,constraintRemainingTimeLeading,constraintRemainingTimeTrailing,constraintCurrentTimeCenter,constraintSliderCenter,constraintRemainingTimeCenter]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startUpdatingMeter];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _audioPlayer.delegate = nil;
    [_audioPlayer stop];
    _audioPlayer = nil;
    
    _audioRecorder.delegate = nil;
    [_audioRecorder stop];
    _audioRecorder = nil;
    
    [self stopUpdatingMeter];
}

#pragma mark - Update Meters

- (void)updateMeters
{
    if (_audioRecorder.isRecording)
    {
        [_audioRecorder updateMeters];
        
        CGFloat normalizedValue = pow (10, [_audioRecorder averagePowerForChannel:0] / 20);
        
        [musicFlowView setWaveColor:_recordingTintColor];
        [musicFlowView updateWithLevel:normalizedValue];
        
        self.navigationItem.title = [NSString timeStringForTimeInterval:_audioRecorder.currentTime];
    }
    else if (_audioPlayer.isPlaying)
    {
        [_audioPlayer updateMeters];
        
        CGFloat normalizedValue = pow (10, [_audioPlayer averagePowerForChannel:0] / 20);
        
        [musicFlowView setWaveColor:_playingTintColor];
        [musicFlowView updateWithLevel:normalizedValue];
    }
    else
    {
        [musicFlowView setWaveColor:_normalTintColor];
        [musicFlowView updateWithLevel:0];
    }
}

-(void)startUpdatingMeter
{
    [meterUpdateDisplayLink invalidate];
    meterUpdateDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [meterUpdateDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)stopUpdatingMeter
{
    [meterUpdateDisplayLink invalidate];
    meterUpdateDisplayLink = nil;
}

#pragma mark - Update Play Progress

-(void)updatePlayProgress
{
    _labelCurrentTime.text = [NSString timeStringForTimeInterval:_audioPlayer.currentTime];
    _labelRemainingTime.text = [NSString timeStringForTimeInterval:(_shouldShowRemainingTime)?(_audioPlayer.duration-_audioPlayer.currentTime):_audioPlayer.duration];
    [_playerSlider setValue:_audioPlayer.currentTime animated:YES];
}

-(void)sliderStart:(UISlider*)slider
{
    _wasPlaying = _audioPlayer.isPlaying;
    
    if (_audioPlayer.isPlaying)
    {
        [_audioPlayer pause];
    }
}

-(void)sliderMoved:(UISlider*)slider
{
    _audioPlayer.currentTime = slider.value;
}

-(void)sliderEnd:(UISlider*)slider
{
    if (_wasPlaying)
    {
        [_audioPlayer play];
    }
}

-(void)tapRecognizer:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _shouldShowRemainingTime = !_shouldShowRemainingTime;
    }
}

-(void)cancelAction:(UIBarButtonItem*)item
{
    if ([self.delegate respondsToSelector:@selector(audioRecorderControllerDidCancel:)])
    {
        IQAudioRecorderController *controller = (IQAudioRecorderController*)[self navigationController];
        [self.delegate audioRecorderControllerDidCancel:controller];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doneAction:(UIBarButtonItem*)item
{
    if ([self.delegate respondsToSelector:@selector(audioRecorderController:didFinishWithAudioAtPath:)])
    {
        IQAudioRecorderController *controller = (IQAudioRecorderController*)[self navigationController];
        [self.delegate audioRecorderController:controller didFinishWithAudioAtPath:_recordingFilePath];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordingButtonAction:(UIBarButtonItem *)item
{
    if (_isRecording == NO)
    {
        _isRecording = YES;

        //UI Update
        {
            [self showNavigationButton:NO];
            _recordButton.tintColor = _recordingTintColor;
            _playButton.enabled = NO;
            _trashButton.enabled = NO;
        }
        
        /*
         Create the recorder
         */
        if ([[NSFileManager defaultManager] fileExistsAtPath:_recordingFilePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:_recordingFilePath error:nil];
        }
        
        _oldSessionCategory = [[AVAudioSession sharedInstance] category];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];
    }
    else
    {
        _isRecording = NO;
        
        //UI Update
        {
            [self showNavigationButton:YES];
            _recordButton.tintColor = _normalTintColor;
            _playButton.enabled = YES;
            _trashButton.enabled = YES;
        }

        [_audioRecorder stop];
        [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    }
}

- (void)playAction:(UIBarButtonItem *)item
{
    _oldSessionCategory = [[AVAudioSession sharedInstance] category];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordingFilePath] error:nil];
    _audioPlayer.delegate = self;
    _audioPlayer.meteringEnabled = YES;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    //UI Update
    {
        [self setToolbarItems:@[_pauseButton,_flexItem1, _recordButton,_flexItem2, _trashButton] animated:YES];
        [self showNavigationButton:NO];
        _recordButton.enabled = NO;
        _trashButton.enabled = NO;
    }
    
    //Start regular update
    {
        _playerSlider.value = _audioPlayer.currentTime;
        _playerSlider.maximumValue = _audioPlayer.duration;
        _viewPlayerDuration.frame = self.navigationController.navigationBar.bounds;
        
        _labelCurrentTime.text = [NSString timeStringForTimeInterval:_audioPlayer.currentTime];
        _labelRemainingTime.text = [NSString timeStringForTimeInterval:(_shouldShowRemainingTime)?(_audioPlayer.duration-_audioPlayer.currentTime):_audioPlayer.duration];

        [_viewPlayerDuration setNeedsLayout];
        [_viewPlayerDuration layoutIfNeeded];
        self.navigationItem.titleView = _viewPlayerDuration;

        [playProgressDisplayLink invalidate];
        playProgressDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayProgress)];
        [playProgressDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)pauseAction:(UIBarButtonItem*)item
{
    //UI Update
    {
        [self setToolbarItems:@[_playButton,_flexItem1, _recordButton,_flexItem2, _trashButton] animated:YES];
        [self showNavigationButton:YES];
        _recordButton.enabled = YES;
        _trashButton.enabled = YES;
    }
    
    {
        [playProgressDisplayLink invalidate];
        playProgressDisplayLink = nil;
        self.navigationItem.titleView = nil;
    }

    _audioPlayer.delegate = nil;
    [_audioPlayer stop];
    _audioPlayer = nil;
    
    [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
}

-(void)deleteAction:(UIBarButtonItem*)item
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Delete Recording" style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction *action) { [self deleteRecordingAction]; }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:action1]; [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)deleteRecordingAction
{
    [[NSFileManager defaultManager] removeItemAtPath:_recordingFilePath error:nil];

    _playButton.enabled = NO;
    _trashButton.enabled = NO;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.navigationItem.title = _navigationTitle;
}

-(void)showNavigationButton:(BOOL)show
{
    if (show)
    {
        [self.navigationItem setLeftBarButtonItem:_cancelButton animated:YES];
        [self.navigationItem setRightBarButtonItem:_doneButton animated:YES];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //To update UI on stop playing
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_pauseButton.target methodSignatureForSelector:_pauseButton.action]];
    invocation.target = _pauseButton.target;
    invocation.selector = _pauseButton.action;
    [invocation invoke];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
//    NSLog(@"%@: %@",NSStringFromSelector(_cmd),error);
}

@end

