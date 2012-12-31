//
//  SongUtils.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/30/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "SongUtils.h"

@implementation SongUtils

+ (NSArray *)getTracksFromSong:(NSManagedObject *)song fromContext:(NSManagedObjectContext *)context {
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    NSString *trackList = [song valueForKey:@"tracks"];
    NSArray *trackDataUrls = [trackList componentsSeparatedByString:@","];
    for (NSString *dataUrl in trackDataUrls) {
        NSURL *url = [NSURL URLWithString:dataUrl];
        NSManagedObjectID *objectId = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
        [tracks addObject:[context objectWithID:objectId]];
    }
    
    return [[NSArray alloc] initWithArray:tracks];
}

+ (BOOL)deleteTrack:(NSManagedObject *)trackData fromContext:(NSManagedObjectContext *)context {
    NSURL *fileUrl = [NSURL fileURLWithPath:[trackData valueForKey:@"fileURL"]];
    [context deleteObject:trackData];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
    if (error) {
        NSLog(@"Error deleting file: %@", [error localizedDescription]);
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:fileUrl.path]) {
            [context undo];
        }
    }
    else {
        [context save:&error];
        
        if (error) {
            NSLog(@"Error deleting managed object for track: %@", [error localizedDescription]);
        }
        
        return YES;
    }
    
    return NO;
}

@end
