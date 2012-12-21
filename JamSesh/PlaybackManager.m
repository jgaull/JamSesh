//
//  PlaybackManager.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "PlaybackManager.h"

@interface PlaybackManager ()

@property (strong, nonatomic) NSMutableArray *song;
@property (strong, nonatomic) NSMutableArray *players;
@property (nonatomic) NSDate *startPlaybackTime;

@property (nonatomic) float songLength;
@property (nonatomic) float playbackStartingLocation;

@end

@implementation PlaybackManager

- (id)initWithTracks:(NSArray *)tracks {
    self = [super init];
    if (self) {
        self.song = [[NSMutableArray alloc] initWithArray:tracks];
        [self reCalculateSongLength];
        _playing = NO;
        _scrubberPosition = 0;
    }
    
    return self;
}

- (void)addTrack:(NSManagedObject *)track {
    if (![self.song containsObject:track]) {
        [self.song addObject:track];
        [self reCalculateSongLength];
    }
}

- (void)removeTrack:(NSManagedObject *)track {
    if ([self.song containsObject:track]) {
        [self.song removeObject:track];
        [self reCalculateSongLength];
    }
}

- (void)play {
    if (self.players == nil) {
        self.players = [[NSMutableArray alloc] init];
    }
    
    for (NSManagedObject *trackData in self.song) {
        if (![[trackData valueForKey:@"muted"] boolValue]) {
            NSURL *url = [NSURL fileURLWithPath:[trackData valueForKey:@"fileURL"]];
            NSError *error = nil;
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:&error];
            
            if (error) {
                NSLog(@"Error loading player track: %@", [error localizedDescription]);
            }
            else {
                float startDelay = [[trackData valueForKey:@"inPoint"] floatValue] - self.scrubberPosition;
                
                if (startDelay > 0 || ABS(startDelay) < [[trackData valueForKey:@"duration"] floatValue]) {
                    player.volume = [[trackData valueForKey:@"volume"] floatValue];
                    player.delegate = self;
                    
                    if (startDelay <= 0) {
                        player.currentTime = ABS(startDelay);
                        [player play];
                    }
                    else {
                        [player playAtTime:player.deviceCurrentTime + startDelay];
                    }
                    
                    [self.players addObject:player];
                }
            }
        }
    }
    
    if (self.players.count > 0) {
        _playing = YES;
        self.startPlaybackTime = [NSDate date];
        self.playbackStartingLocation = self.scrubberPosition;
        [self scrubberUpdateLoopBegin];
    }
    else {
        [self endPlayback];
    }
}

- (void)stop {
    if (_playing) {
        for (AVAudioPlayer *player in self.players) {
            [player stop];
        }
        
        [self endPlayback];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    player.delegate = nil;
    [self.players removeObject:player];
    
    if (self.players.count == 0) {
        [self endPlayback];
        self.scrubberPosition = self.songLength;
    }
}

- (void)endPlayback {
    _playing = NO;
    [self scrubberUpdateLoopEnd];
    self.startPlaybackTime = nil;
    self.players = nil;
    
    if ([self.delegate respondsToSelector:@selector(playbackManagerDidFinishPlaying:)]) {
        [self.delegate playbackManagerDidFinishPlaying:self];
    }
}

- (void)reCalculateSongLength {
    float length = 0;
    for (NSManagedObject *trackData in self.song) {
        length = MAX([[trackData valueForKey:@"inPoint"] floatValue] + [[trackData valueForKey:@"duration"] floatValue], length);
    }
    
    _songLength = length;
}

- (void)setScrubberPosition:(float)scrubberPosition {
    if (self.playing) {
        [self stop];
    }
    
    _scrubberPosition = scrubberPosition;
    
    if ([self.delegate respondsToSelector:@selector(playbackManagerScrubberDidMove:)]) {
        [self.delegate playbackManagerScrubberDidMove:self];
    }
}

- (void)updateScrubberPosition {
    NSTimeInterval timePassed = ABS([self.startPlaybackTime timeIntervalSinceNow]);
    _scrubberPosition = timePassed + self.playbackStartingLocation;
    
    if ([self.delegate respondsToSelector:@selector(playbackManagerScrubberDidMove:)]) {
        [self.delegate playbackManagerScrubberDidMove:self];
    }
    
}

- (void)scrubberUpdateLoopBegin {
    static float updateFrequency = 0.03;
    [self performSelector:@selector(scrubberUpdateLoopBegin) withObject:nil afterDelay:updateFrequency];
    [self updateScrubberPosition];
}

- (void)scrubberUpdateLoopEnd {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrubberUpdateLoopBegin) object:nil];
}

- (float)songLength {
    return _songLength;
}

@end
