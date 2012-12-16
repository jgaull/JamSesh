//
//  ViewController.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/2/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) int state;

@property (strong, nonatomic) NSDictionary *recordSettings;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSMutableArray *audioTracks;
@property (strong, nonatomic) NSMutableArray *audioPlayers;
@property (strong, nonatomic) AVAudioRecorder *currentTrack;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //self.playButton.enabled = NO;
    //self.stopButton.enabled = NO;
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.basePath = [dirPaths objectAtIndex:0];
    
    self.recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    self.state = kIdle;
    self.audioTracks = [[NSMutableArray alloc] init];
    
    //NSError *error = nil;
    
    /*self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:self.recordSettings error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        [self.audioRecorder prepareToRecord];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (IBAction)onRecordTouched:(id)sender {
    [self recordAudio];
}

- (IBAction)onPlayTouched:(id)sender {
    [self playAudio];
}

- (IBAction)onStopTouched:(id)sender {
    [self stop];
}

-(void) recordAudio
{
        //self.playButton.enabled = NO;
        //self.stopButton.enabled = YES;
        
        NSString *soundFilePath = [self.basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"track%d.caf", self.audioTracks.count]];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        NSError *error = nil;
        self.currentTrack = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:self.recordSettings error:&error];
        [self.currentTrack record];
        
        [self playAllRecordedTracks];
        
        self.state = kRecording;
        
        NSLog(@"recording!");
}
-(void)stop
{
    //self.stopButton.enabled = NO;
    //self.playButton.enabled = YES;
    //self.recordButton.enabled = YES;
    
    if (self.state == kRecording)
    {
        [self.currentTrack stop];
        [self.audioTracks addObject:self.currentTrack];
        self.currentTrack = nil;
        [self stopPlayingAllRecordedTracks];
        
        NSLog(@"stop recording!");
    }
    else if (self.state == kPlaying)
    {
        [self stopPlayingAllRecordedTracks];
        
        NSLog(@"stop playing!");
        
    }
    
    self.state = kIdle;
}
-(void) playAudio
{
    if (self.state == kIdle)
    {
        //self.stopButton.enabled = YES;
        //self.recordButton.enabled = NO;
        
        [self playAllRecordedTracks];
        
        self.state = kPlaying;
        
        NSLog(@"play!");
    }
}

- (void)playAllRecordedTracks
{
    self.audioPlayers = [[NSMutableArray alloc] init];
    for (AVAudioRecorder *audioTrack in self.audioTracks) {
        NSError *error = nil;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioTrack.url error:&error];
        player.delegate = self;
        [self.audioPlayers addObject:player];
        
        if (error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else
        {
            [player play];
        }
    }
}

- (void)stopPlayingAllRecordedTracks
{
    for (AVAudioPlayer *player in self.audioPlayers) {
        [player stop];
    }
    
    self.audioPlayers = nil;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player play];
}

@end
