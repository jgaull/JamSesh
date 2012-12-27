//
//  PlaybackControlsViewController.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/25/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "PlaybackControlsViewController.h"

@interface PlaybackControlsViewController ()

@property (strong, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation PlaybackControlsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self.playButton addTarget:self action:@selector(onPlayButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayButton:(id)sender {
    if (self.playbackManager.playing) {
        [self.playbackManager stop];
        [self.playButton setTitle:@">" forState:UIControlStateNormal];
    }
    else {
        [self.playbackManager play];
        [self.playButton setTitle:@"||" forState:UIControlStateNormal];
    }
}

- (IBAction)onBackButton:(id)sender {
    self.playbackManager.scrubberPosition = 0;
}

- (void)playbackManagerDidFinishPlaying:(PlaybackManager *)manager {
    [self.playButton setTitle:@">" forState:UIControlStateNormal];
}

- (void)playbackManagerScrubberDidMove:(PlaybackManager *)manager {
    float targetValue = self.playbackManager.scrubberPosition / self.playbackManager.songLength;
    if (self.scrubberBar.value != targetValue) {
        self.scrubberBar.value = targetValue;
    }
}

@end
