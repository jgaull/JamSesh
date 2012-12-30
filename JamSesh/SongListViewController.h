//
//  SongListViewController.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/29/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SongListViewController : UITableViewController

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
