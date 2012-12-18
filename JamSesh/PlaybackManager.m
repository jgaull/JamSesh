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

@end

@implementation PlaybackManager

- (id)initWithTracks:(NSArray *)tracks {
    self = [super init];
    if (self) {
        self.song = [[NSMutableArray alloc] initWithArray:tracks];
        _playing = NO;
    }
    
    return self;
}

- (void)addTrack:(NSManagedObject *)track {
    if (![self.song containsObject:track]) {
        [self.song addObject:track];
    }
}

- (void)removeTrack:(NSManagedObject *)track {
    if ([self.song containsObject:track]) {
        [self.song removeObject:track];
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
                player.volume = [[trackData valueForKey:@"volume"] floatValue];
                player.delegate = self;
                [player play];
                [self.players addObject:player];
            }
        }
    }
    
    if (self.players.count > 0) {
        _playing = YES;
        self.numCompletedPlayers = 0;
    }
    else {
        [self endPlayback];
    }
}

- (void)stop {
    if (_playing) {
        for (AVAudioPlayer *player in self.players) {
            [player stop];
            player.delegate = nil;
        }
        
        self.players = nil;
        
        _playing = NO;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.numCompletedPlayers++;
    
    if (self.numCompletedPlayers == self.players.count) {
        [self endPlayback];
    }
}

- (void)endPlayback {
    
    self.players = nil;
    
    if ([self.delegate respondsToSelector:@selector(playbackManagerDidFinishPlaying:)]) {
        [self.delegate playbackManagerDidFinishPlaying:self];
    }
}

- (void)setScrubberPosition:(double)scrubberPosition {
    if (!self.playing) {
        _scrubberPosition = scrubberPosition;
    }
}

@end
