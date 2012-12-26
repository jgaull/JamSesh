//
//  RecordedTrackViewDelegate.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/25/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "RecordedTrackCellDelegate.h"

@interface RecordedTrackCellDelegate ()

@end

@implementation RecordedTrackCellDelegate

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context andTracks:(NSArray *)tracks{
    self = [super init];
    if (self) {
        self.managedObjectConext = context;
    }
    
    return self;
}

- (void)recordedTrackCellMuteDidChange:(RecordedTrackCell *)cell value:(BOOL)value {
    
}

- (void)recordedTrackCellVolumeDidChange:(RecordedTrackCell *)cell value:(float)value {
    
}

- (void)recordedTrackCellUserDidSave:(RecordedTrackCell *)cell {
    
}

- (void)recordedTrackCellUserDidCancel:(RecordedTrackCell *)cell {
    
}

//- (void)onTrackDataChanged:(NSNotification *)note {
//    
//}
//
//- (void)onContextSave:(NSNotification *)note {
//    
//}
//
//- (void)setManagedObjectConext:(NSManagedObjectContext *)managedObjectConext {
//    if (_managedObjectConext != managedObjectConext) {
//        if (_managedObjectConext) {
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:_managedObjectConext];
//        }
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTrackDataChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:managedObjectConext];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectConext];
//        _managedObjectConext = managedObjectConext;
//    }
//}

@end
