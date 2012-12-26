//
//  RecordViewController.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>

#import "PlaybackManager.h"
#import "RecordedTrackCell.h"

static const int kIdle = 0;
static const int kPlaying = 1;
static const int kArmed = 2;
static const int kRecording = 3;
static const int kPendingSave = 4;
static const int kPreviewing = 5;

@interface RecordViewController : UIViewController <AVAudioRecorderDelegate, PlaybackManagerDelegate, UITableViewDataSource, UITableViewDelegate, RecordedTrackCellDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)playbackManagerDidFinishPlaying:(PlaybackManager *)manager;
- (void)playbackManagerScrubberDidMove:(PlaybackManager *)manager;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)appResignActive;
- (void)appBecomeActive;

- (void)recordedTrackCellVolumeDidChange:(RecordedTrackCell *)cell value:(float)value;
- (void)recordedTrackCellMuteDidChange:(RecordedTrackCell *)cell value:(BOOL)value;
- (void)recordedTrackCellUserDidCancel:(RecordedTrackCell *)cell;
- (void)recordedTrackCellUserDidSave:(RecordedTrackCell *)cell;

@end
