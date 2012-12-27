//
//  NewTrackView.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import "NewTrackView.h"
#import "RecordViewController.h"

@interface NewTrackView ()

@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) int state;

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *createNewTrackLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;

@end

@implementation NewTrackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.state = kIdle;
    }
    return self;
}

- (IBAction)onRecordButton:(id)sender {
    
    switch (self.state) {
        case kIdle:
            [self becomeArmed];
            break;
        case kArmed:
            [self startRecording];
            break;
        case kRecording:
            [self becomeIdle];
            break;
    }
}

- (IBAction)onCancelButton:(id)sender {
    [self becomeIdle];
    
    if ([self.delegate respondsToSelector:@selector(newTrackViewDisarm:)]) {
        [self.delegate newTrackViewDisarm:self];
    }
}

- (void)becomeIdle {
    if (self.state == kRecording) {
        [self stopRecording];
    }
    
    self.state = kIdle;
    self.timerLabel.text = @"00:00.0";
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    self.timerLabel.hidden = YES;
    self.createNewTrackLabel.hidden = NO;
    self.cancelButton.hidden = YES;
}

- (void)becomeArmed {
    if ([self.delegate newTrackViewShouldArmForRecording:self]) {
        self.state = kArmed;
        [self.recordButton setTitle:@"Start" forState:UIControlStateNormal];
        self.cancelButton.hidden = NO;
        self.timerLabel.hidden = NO;
        self.createNewTrackLabel.hidden = YES;
    }
}

- (void)startRecording {
    if ([self.delegate newTrackViewShouldBeginRecording:self]) {
        self.state = kRecording;
        [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.cancelButton.hidden = YES;
        self.startTime = [NSDate date];
        [self updateTimer];
    }
}

- (void)stopRecording {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTimer) object:nil];
    
    if ([self.delegate respondsToSelector:@selector(newTrackViewEndRecording:)]) {
        [self.delegate newTrackViewEndRecording:self];
    }
}

- (void)updateTimer {
    float timePassed = ABS([self.startTime timeIntervalSinceNow]);
    long time = timePassed;
    long preciseTime = timePassed * 10;
    
    int minutes = timePassed / 60;
    int seconds = time % 60;
    int tenths = preciseTime % 10;
    
    self.timerLabel.text = [NSString stringWithFormat:@"%d:%d.%d", minutes, seconds, tenths];
    [self performSelector:@selector(updateTimer) withObject:nil afterDelay:0.01];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
