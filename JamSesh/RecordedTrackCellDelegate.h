//
//  RecordedTrackViewDelegate.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/25/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RecordedTrackCell.h"

@interface RecordedTrackCellDelegate : NSObject <RecordedTrackCellDelegate>

@property (nonatomic, weak) NSManagedObjectContext *managedObjectConext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context andTracks:(NSArray *)tracks;
- (void)recordedTrackCellMuteDidChange:(RecordedTrackCell *)cell value:(BOOL)value;
- (void)recordedTrackCellVolumeDidChange:(RecordedTrackCell *)cell value:(float)value;
- (void)recordedTrackCellUserDidSave:(RecordedTrackCell *)cell;
- (void)recordedTrackCellUserDidCancel:(RecordedTrackCell *)cell;

@end
