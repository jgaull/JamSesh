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

@protocol PlaybackManagerDelegate;

@interface PlaybackManager : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, weak) id <PlaybackManagerDelegate> delegate;
@property (nonatomic) float scrubberPosition;
@property (nonatomic, readonly) float songLength;

- (id)initWithTracks:(NSArray *)tracks andContext:(NSManagedObjectContext *)managedObjectContext;
- (void)addTrack:(NSManagedObject *)track;
- (void)removeTrack:(NSManagedObject *)track;
- (void)play;
- (void)stop;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end

@protocol PlaybackManagerDelegate <NSObject>
@optional

- (void)playbackManagerDidFinishPlaying:(PlaybackManager *)manager;
- (void)playbackManagerScrubberDidMove:(PlaybackManager *)manager;

@end
