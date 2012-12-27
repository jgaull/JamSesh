//
//  RecordViewController.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import "RecordViewController.h"
#import "NewTrackView.h"
#import "RecordedTrackCell.h"
#import "PlaybackManager.h"
#import "PlaybackControlsViewController.h"

@interface RecordViewController ()

@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSDictionary *recordSettings;

@property (strong, nonatomic) AVAudioRecorder *currentTrack;
@property (strong, nonatomic) PlaybackManager *playbackManager;
@property (strong, nonatomic) PlaybackControlsViewController *playbackControls;

@property (strong, nonatomic) NSMutableArray *recordedTracksData;

@property (nonatomic) float currentTrackInTime;
@property (nonatomic) BOOL pendingSave;

@property (strong, nonatomic) IBOutlet UISlider *scrubberBar;

@end

@interface RecordViewController ()

@end

@implementation RecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.editButtonItem.action = @selector(onEdit);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //create data and fill it up here.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrackModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.recordedTracksData = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    self.playbackManager = [[PlaybackManager alloc] initWithTracks:self.recordedTracksData andContext:self.managedObjectContext];
    self.playbackManager.delegate = self;
    
    //register the table view cells that we'll be using.
    [self.tableView registerNib:[UINib nibWithNibName:@"NewTrackView" bundle:nil] forCellReuseIdentifier:@"NewTrackView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordedTrackView" bundle:nil] forCellReuseIdentifier:@"RecordedTrackView"];
    
    //set up a path to store our recordings.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.basePath = [dirPaths objectAtIndex:0];
    self.recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:AVAudioQualityMin],
                           AVEncoderAudioQualityKey,
                           [NSNumber numberWithInt:16],
                           AVEncoderBitRateKey,
                           [NSNumber numberWithInt: 1],
                           AVNumberOfChannelsKey,
                           [NSNumber numberWithFloat:44100.0],
                           AVSampleRateKey,
                           nil];
    
    //set up some UI
    self.scrubberBar.maximumValue = 1;
    self.scrubberBar.value = self.playbackManager.scrubberPosition;
    
    //Create the playback controls
    PlaybackControlsViewController *playbackControls = [[PlaybackControlsViewController alloc] initWithNibName:@"PlaybackControlsView" bundle:nil];
    self.playbackControls = playbackControls;
    playbackControls.playbackManager = self.playbackManager;
    self.navigationItem.titleView = playbackControls.view;
    self.playbackControls.scrubberBar = self.scrubberBar;
    self.playbackManager.delegate = self.playbackControls;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appResignActive {
#warning Need to delete disarm if armed
#warning need to stop playing if playing
}

- (void)appBecomeActive {
    
}

#pragma mark - Button Listeners

- (IBAction)scrubberBar:(id)sender {
    self.playbackManager.scrubberPosition = self.playbackManager.songLength * self.scrubberBar.value;
#warning The scrubber bar should be a part of the playback controls
}

- (void)onEdit {
    [self.playbackManager stop];
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    UIBarButtonItemStyle style = self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
    NSString *title = self.tableView.editing ? @"Done" : @"Edit";
    
    self.navigationItem.rightBarButtonItem.style = style;
    self.navigationItem.rightBarButtonItem.title = title;
}

#pragma mark - the magic

- (void)disarm {
    //delete the recorded track and lose the reference to it. Bye!
    [self.currentTrack deleteRecording];
    self.currentTrack = nil;
    
    self.pendingSave = NO;
}

- (void)saveRecording {
    self.pendingSave = NO;
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.recordedTracksData.count inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.recordedTracksData.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Table View Delegate

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row != self.recordedTracksData.count) {
        return YES;
    }
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteRowAtIndexPath:indexPath];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath {
    // Delete the row from the data source
    NSManagedObject *trackData = [self.recordedTracksData objectAtIndex:indexPath.row];
    NSURL *fileUrl = [NSURL fileURLWithPath:[trackData valueForKey:@"fileURL"]];
    [self.recordedTracksData removeObject:trackData];
    [self.playbackManager removeTrack:trackData];
    [self.managedObjectContext deleteObject:trackData];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
    
    if (error) {
        NSLog(@"Error deleting file: %@", [error localizedDescription]);
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:fileUrl.path]) {
            [self.managedObjectContext undo];
        }
    }
    else {
        [self.managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"Error deleting managed object for track: %@", [error localizedDescription]);
        }
    }
    
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    if (self.recordedTracksData.count == 0) {
        [self onEdit];
    }
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
    //The number of tracks + 1 for the "Create New" track.
    return self.pendingSave ? self.recordedTracksData.count : self.recordedTracksData.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIViewController *tempViewController;
    
    if (indexPath.row == self.recordedTracksData.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewTrackView" forIndexPath:indexPath];
        
        if (cell == nil) {
            tempViewController = [[UIViewController alloc] initWithNibName:@"NewTrackView" bundle:nil];
            cell = (UITableViewCell *)tempViewController.view;
        }
        
        NewTrackView *createNewTrackView = (NewTrackView *)cell;
        createNewTrackView.delegate = self;
    }
    else {
        NSManagedObject *data = [self.recordedTracksData objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"RecordedTrackView" forIndexPath:indexPath];
        RecordedTrackCell *recordedTrack = (RecordedTrackCell *)cell;
        
        if (cell == nil) {
            recordedTrack = (RecordedTrackCell *)[[UIViewController alloc] initWithNibName:@"RecordedTrackView" bundle:nil];
            cell = recordedTrack;
        }
        
        recordedTrack.trackLabel.text = [data valueForKey:@"name"];
        recordedTrack.muteSwitch.on = ![[data valueForKey:@"muted"] boolValue];
        recordedTrack.volumeSlider.value = [[data valueForKey:@"volume"] floatValue];
        recordedTrack.tag = indexPath.row;
        recordedTrack.pendingSave = NO;
        recordedTrack.delegate = self;
        
        if (self.pendingSave && indexPath.row == self.recordedTracksData.count - 1) {
            recordedTrack.pendingSave = YES;
        }
    }
    
    return cell;
}

#pragma mark - New Track Cell Delegate

- (BOOL)newTrackViewShouldArmForRecording:(NewTrackView *)newTrackView {
    //setup necessary info for creating a recording track
    int now = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d_%d.caf", now, arc4random() % 100000];
    NSString *soundFilePath = [self.basePath stringByAppendingPathComponent:fileName];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSError *error = nil;
    self.currentTrack = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:self.recordSettings error:&error];
    if (error) {
        NSLog(@"Error creating recorder: %@", [error localizedDescription]);
    }
    else {
        
        //arm the track
        [self.currentTrack prepareToRecord];
        [self.playbackManager stop];
        
        //setup the UI
        self.navigationItem.titleView = nil;
        self.navigationItem.title = @"Record";
        self.navigationItem.rightBarButtonItem = nil;
        
        return YES;
    }
    
    return NO;
}

- (BOOL)newTrackViewShouldBeginRecording:(NewTrackView *)newTrackView {
    self.pendingSave = YES;
    [self.currentTrack record];
    self.currentTrackInTime = self.playbackManager.scrubberPosition;
    
    return YES;
#warning I need to handle the edit button while recording/armed
}

- (void)newTrackViewEndRecording:(NewTrackView *)newTrackView {
    //figure out the duration of the track first, otherwise it's 0
    float currentTrackDuration = self.currentTrack.currentTime;
    
    //stop everything!
    [self.currentTrack stop];
    [self.playbackManager stop];
    
    //This gets the date the track was recorded on so we can set a default name
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString *trackName = [dateFormatter stringFromDate:[NSDate date]];
    
    //Create an object for CoreData and save it to the database
    NSManagedObjectContext *context = self.managedObjectContext;
    NSManagedObject *trackModel = [NSEntityDescription insertNewObjectForEntityForName:@"TrackModel" inManagedObjectContext:context];
    [trackModel setValue:self.currentTrack.url.filePathURL.path forKey:@"fileURL"];
    [trackModel setValue: trackName forKey:@"name"];
    [trackModel setValue:[NSNumber numberWithDouble:currentTrackDuration] forKey:@"duration"];
    [trackModel setValue:[NSNumber numberWithDouble:self.currentTrackInTime] forKey:@"inPoint"];
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"Coulnd't save track! %@", [error localizedDescription]);
    }
    else { //If the save was successful
        
        //add the track
        [self.recordedTracksData addObject:trackModel];
        [self.playbackManager addTrack:trackModel];
        
        //nill out reference to the recorder for this track since we don't need it and reset some shit for no reason
        self.currentTrack = nil;
        self.currentTrackInTime = 0;
        
        //update the table view so that it shows the track pending save and no longer shows the new track
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.recordedTracksData.count - 1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.recordedTracksData.count - 1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
        
        //Put back the playback controls
        self.navigationItem.titleView = self.playbackControls.view;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (void)newTrackViewDisarm:(NewTrackView *)newTrackView {
    [self disarm];
}

#pragma mark - Recorded Track Cell Delegate

- (void)recordedTrackCellVolumeDidChange:(RecordedTrackCell *)cell value:(float)value {
    NSManagedObject *data = [self.recordedTracksData objectAtIndex:cell.tag];
    [data setValue:[NSNumber numberWithFloat:cell.volumeSlider.value] forKey:@"volume"];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Oops. Error saving your muting of the track duder: %@", [error localizedDescription]);
    }
}

- (void)recordedTrackCellMuteDidChange:(RecordedTrackCell *)cell value:(BOOL)value {
    NSManagedObject *data = [self.recordedTracksData objectAtIndex:cell.tag];
#warning This will throw an error if the user deletes any tracks.
    [data setValue:[NSNumber numberWithBool:!cell.muteSwitch.on] forKey:@"muted"];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Oops. Error saving your muting of the track duder: %@", [error localizedDescription]);
    }
}

- (void)recordedTrackCellUserDidCancel:(RecordedTrackCell *)cell {
    [self disarm];
    [self.tableView beginUpdates];
#warning This should probably change. It's weird to not make the call directly to the table view
    [self deleteRowAtIndexPath:[NSIndexPath indexPathForRow:self.recordedTracksData.count - 1 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.recordedTracksData.count inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    cell.pendingSave = NO;
}

- (void)recordedTrackCellUserDidSave:(RecordedTrackCell *)cell {
    [self saveRecording];
    cell.pendingSave = NO;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
