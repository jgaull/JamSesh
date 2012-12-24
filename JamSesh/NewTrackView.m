//
//  NewTrackView.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import "NewTrackView.h"
#import "RecordViewController.h"
#import "Utils.h"

@interface NewTrackView ()

@property (strong, nonatomic) NSDate *startTime;

@end

@implementation NewTrackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setState:(int)state {
    if (state != _state) {
        
        [self resetView];
        
        switch (state) {
            case kIdle:
            case kPlaying:
            case kPendingSave:
            case kPreviewing:
                self.createNewTrackLabel.hidden = NO;
                self.recordButton.hidden = NO;
                [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
                [self stopRecording];
                break;
            case kArmed:
                self.cancelButton.hidden = NO;
                self.timerLabel.hidden = NO;
                self.recordButton.hidden = NO;
                [self.recordButton setTitle:@"Start" forState:UIControlStateNormal];
                self.timerLabel.text = @"00:00:00";
                break;
            case kRecording:
                self.cancelButton.hidden = NO;
                self.timerLabel.hidden = NO;
                self.recordButton.hidden = NO;
                [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
                [self startRecording];
                break;
            default:
                break;
        }
        
        _state = state;
    }
}

- (void)resetView {
    self.createNewTrackLabel.hidden = YES;
    self.recordButton.hidden = YES;
    self.timerLabel.hidden = YES;
    self.cancelButton.hidden = YES;
}

- (void)startRecording {
    self.startTime = [NSDate date];
    [self updateTimer];
}

- (void)stopRecording {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTimer) object:nil];
}

- (void)updateTimer {
    NSDictionary *timeMap = [Utils createTimemapForSeconds:ABS([self.startTime timeIntervalSinceNow])];
    self.timerLabel.text = [NSString stringWithFormat:@"%@:%@:%@", [timeMap objectForKey:@"m"], [timeMap objectForKey:@"s"], [timeMap objectForKey:@"hundreths"]];
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
