//
//  PlaybackControlsViewController.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/25/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaybackManager.h"

@interface PlaybackControlsViewController : UIViewController <PlaybackManagerDelegate>

@property (weak, nonatomic) PlaybackManager *playbackManager;
@property (weak, nonatomic) UISlider *scrubberBar;

- (void)playbackManagerDidFinishPlaying:(PlaybackManager *)manager;
- (void)playbackManagerScrubberDidMove:(PlaybackManager *)manager;

@end
