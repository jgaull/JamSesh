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

static const int kIdle = 0;
static const int kPlaying = 1;
static const int kRecording = 2;
static const int kOther = 3;

@interface RecordViewController : UITableViewController < AVAudioRecorderDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
