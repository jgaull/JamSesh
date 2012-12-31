//
//  SongListViewController.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/29/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "SongListViewController.h"
#import "RecordViewController.h"
#import "SongUtils.h"

@interface SongListViewController ()

@property (strong, nonatomic) NSMutableArray *songs;

@end

@implementation SongListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //load the data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SongModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.songs = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SongCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *songData = [self.songs objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [songData valueForKey:@"name"];
    cell.detailTextLabel.text = [songData valueForKey:@"createDate"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Button Listeners

- (IBAction)onNew:(UIBarButtonItem *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString *createDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSManagedObject *songModel = [NSEntityDescription insertNewObjectForEntityForName:@"SongModel" inManagedObjectContext:self.managedObjectContext];
    [songModel setValue:createDate forKey:@"name"];
    [songModel setValue:[NSDate date] forKey:@"createDate"];
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Coulnd't save track! %@", [error localizedDescription]);
    }
    else {
        [self.songs addObject:songModel];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.songs.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObject *songData = [self.songs objectAtIndex:indexPath.row];
        NSArray *trackList = [SongUtils getTracksFromSong:songData fromContext:self.managedObjectContext];
        BOOL aFailure = NO;
        for (NSManagedObject *track in trackList) {
            ;
            if (![SongUtils deleteTrack:track fromContext:self.managedObjectContext]) {
                aFailure = YES;
            }
        }
        
        if (!aFailure) {
            
            [self.managedObjectContext deleteObject:songData];
            NSError *error = nil;
            [self.managedObjectContext save:&error];
            if (error) {
                NSLog(@"Error deleting song from database: %@", [error localizedDescription]);
            }
            else {
                [self.songs removeObject:songData];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                if (self.songs.count == 0) {
                    self.editing = NO;
                }
            }
        }
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //this seems hacky
    [self performSegueWithIdentifier:@"RecordViewSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RecordViewController *recordView = segue.destinationViewController;
    recordView.song = [self.songs objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    recordView.managedObjectContext = self.managedObjectContext;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != managedObjectContext) {
        _managedObjectContext = managedObjectContext;
    }
}

@end
