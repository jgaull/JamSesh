//
//  PlaybackManager.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "PlaybackManager.h"

@interface PlaybackManager ()

@property (strong, nonatomic) NSMutableDictionary *song;

@end

@implementation PlaybackManager

- (id)initWithTracks:(NSMutableArray *)tracks {
    self = [super init];
    if (self) {
        for (NSManagedObject *track in tracks) {
            [self addTrack:track];
        }
    }
    
    return self;
}

- (void)addTrack:(NSManagedObject *)track {
//        if (self.song == nil) {
//            self.song = [[NSMutableDictionary alloc] init];
//        }
//        
//        NSError *error = nil;
//        NSURL *trackUrl = [NSURL fileURLWithPath:[track valueForKey:@"fileURL"]];
//        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:trackUrl error:&error];
//        
//        if (error) {
//            NSLog(@"Error loading audio player: %@", [error localizedDescription]);
//        }
//        else {
//            player.delegate = self;
//            [self.song setObject:player forKey:track];
//            
//            if (![[trackData valueForKey:@"muted"] boolValue]) {
//                self.numUnmutedTracks++;
//            }
//        }
//    }
}

- (void)muteTrack:(NSString *)track {
    
}

- (void)play {
    
}

- (void)stop {
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
}

@end
