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

@property (nonatomic) int numCompletedPlayers;
@property (nonatomic) float songLength;
@property (nonatomic) float lastUpdateTime;

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
        self.numCompletedPlayers = 0;
        self.lastUpdateTime = [self getDeviceTime];
        [self updateScrubberPositionDuringPlayback];
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
    self.numCompletedPlayers++;
    
    if (self.numCompletedPlayers == self.players.count) {
        [self endPlayback];
    }
}

- (void)endPlayback {
    _playing = NO;
    if (self.players.count > 0) {
        self.scrubberPosition = [self getDeviceTime] - self.lastUpdateTime;
    }
    
    self.players = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateScrubberPositionDuringPlayback) object:nil];
    
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

- (void)updateScrubberPositionDuringPlayback {
    static float updateFrequency = 0.03;
    AVAudioPlayer *aPlayer = [self.players objectAtIndex:0];
    float timePassed = aPlayer.deviceCurrentTime - self.lastUpdateTime;
    self.lastUpdateTime = aPlayer.deviceCurrentTime;
    _scrubberPosition += timePassed;
    
    if ([self.delegate respondsToSelector:@selector(playbackManagerScrubberDidMove:)]) {
        [self.delegate playbackManagerScrubberDidMove:self];
    }
    
    [self performSelector:@selector(updateScrubberPositionDuringPlayback) withObject:nil afterDelay:updateFrequency];
}

- (float)getDeviceTime {
    AVAudioPlayer *player = [self.players objectAtIndex:0];
    return player.deviceCurrentTime;
}

- (float)songLength {
    return _songLength;
}

@end
