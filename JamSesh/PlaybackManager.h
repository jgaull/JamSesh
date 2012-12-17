//
//  PlaybackManager.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>

@interface PlaybackManager : NSObject <AVAudioPlayerDelegate>

- (id)initWithTracks:(NSMutableArray *)tracks;
- (void)addTrack:(NSManagedObject *)track;
- (void)muteTrack:(NSString *)name;
- (void)play;
- (void)stop;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end
