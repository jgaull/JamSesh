//
//  SongUtils.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/30/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SongUtils : NSObject

+ (NSArray *)getTracksFromSong:(NSManagedObject *)song fromContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteTrack:(NSManagedObject *)trackData fromContext:(NSManagedObjectContext *)context;

@end
