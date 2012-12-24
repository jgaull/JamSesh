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
#import "PlaybackControllsView.h"

@interface RecordViewController ()

@property (nonatomic) int state;

@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) AVAudioRecorder *currentTrack;
@property (strong, nonatomic) PlaybackManager *playbackManager;

@property (strong, nonatomic) NSMutableArray *recordedTracksData;
@property (strong, nonatomic) NSDictionary *recordSettings;

@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UISlider *scrubberBar;

@property (strong, nonatomic) NewTrackView *createNewTrackView;
@property (strong, nonatomic) RecordedTrackCell *pendingSaveTrackCell;

@property (nonatomic) float currentTrackInTime;

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
    
    //create data and fill it up here. Will probably have to load tracks from storage.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrackModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.recordedTracksData = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    self.playbackManager = [[PlaybackManager alloc] initWithTracks:self.recordedTracksData andContext:self.managedObjectContext];
    self.playbackManager.delegate = self;
    
    //register the table views that we'll be using.
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
    
    //some things that need to be set before the magic happens.
    self.state = kIdle;
    
    //set up some UI
    self.scrubberBar.maximumValue = 1;
    self.scrubberBar.value = self.playbackManager.scrubberPosition;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appResignActive {
    switch (self.state) {
        case kIdle:
            [self.currentTrack deleteRecording];
            self.currentTrack = nil;
            break;
        case kRecording:
            [self stopRecording];
            break;
        case kPlaying:
            [self stopPlaying];
            break;
        case kArmed:
            [self disarm];
        default:
            break;
    }
}

- (void)appBecomeActive {
    
}

#pragma mark - Button Listeners

- (void)onRecord:(id)sender forEvent:(UIEvent *)event {
    if (!self.tableView.editing) {
        if (self.state == kIdle) {
            [self arm];
            self.state = kArmed;
        }
        else if (self.state == kArmed) {
            [self recordAudio];
            self.state = kRecording;
        }
        else if (self.state == kRecording) {
            self.state = kPendingSave;
            [self stopRecording];
        }
    }
}

- (IBAction)onPlay:(id)sender {
    if (!self.tableView.editing) {
        if (self.state == kPlaying) {
            [self stopPlaying];
            self.state = kIdle;
        }
        else if (self.state == kPendingSave) {
            [self playAudio];
            self.state = kPreviewing;
        }
        else if (self.state == kIdle) {
            [self playAudio];
            self.state = kPlaying;
        }
        else if (self.state = kPreviewing) {
            [self stopPlaying];
            self.state = kPendingSave;
        }
    }
}

- (void)onMute:(UISwitch *)sender forEvent:(UIEvent *)event {
    NSManagedObject *data = [self.recordedTracksData objectAtIndex:sender.tag];
    [data setValue:[NSNumber numberWithBool:!sender.on] forKey:@"muted"];
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Oops. Error saving your muting of the track duder: %@", [error localizedDescription]);
    }
}

- (void)onAdjustVolume:(UISlider *)sender forEvent:(UIEvent *)event {
    NSManagedObject *data = [self.recordedTracksData objectAtIndex:sender.tag];
    [data setValue:[NSNumber numberWithFloat:sender.value] forKey:@"volume"];
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Oops. Error saving your muting of the track duder: %@", [error localizedDescription]);
    }
}

- (IBAction)scrubberBar:(id)sender {
    self.playbackManager.scrubberPosition = self.playbackManager.songLength * self.scrubberBar.value;
}

- (void)onEdit {
    [self.playbackManager stop];
    [self.tableView setEditing:!self.tableView.editing animated:YES];
     
    UIBarButtonItemStyle style = self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
    NSString *title = self.tableView.editing ? @"Done" : @"Edit";
    
    self.navigationItem.rightBarButtonItem.style = style;
    self.navigationItem.rightBarButtonItem.title = title;
}

- (IBAction)onSkipBack:(id)sender {
    self.playbackManager.scrubberPosition = 0;
}

- (void)onCancelRecording:(id)sender forEvent:(UIEvent *)event {
    if (self.state == kArmed || self.state == kPendingSave) {
        [self disarm];
        self.state = kIdle;
        [self.tableView beginUpdates];
        [self deleteRowAtIndexPath:[NSIndexPath indexPathForRow:self.recordedTracksData.count - 1 inSection:0]];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.recordedTracksData.count inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        [self noMorePendingTrackCell];
    }
}

- (void)onSaveRecording:(id)sender forEvent:(UIEvent *)event {
    self.state = kIdle;
    [self saveRecording];
    [self noMorePendingTrackCell];
}

#pragma mark - the magic

-(void)recordAudio
{
    [self.currentTrack record];
    self.currentTrackInTime = self.playbackManager.scrubberPosition;
    self.title = @"Recording";
}

-(void)stopRecording
{
    float currentTrackDuration = self.currentTrack.currentTime;
    [self.currentTrack stop];
    [self.playbackManager stop];
    
    //write the info about the new track to the database
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString *trackName = [dateFormatter stringFromDate:[NSDate date]];
    
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
    else {
        [self.recordedTracksData addObject:trackModel];
        [self.playbackManager addTrack:trackModel];
        self.currentTrack = nil;
        self.currentTrackInTime = 0;
        
        self.title = nil;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.recordedTracksData.count - 1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.recordedTracksData.count - 1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    }
}

- (void)stopPlaying {
    
    if (self.playbackManager.playing) {
        [self.playbackManager stop];
    }
    
    [self.playButton setTitle:@">" forState:UIControlStateNormal];
}

-(void)playAudio
{
    [self.playButton setTitle:@"||" forState:UIControlStateNormal];
    [self.playbackManager play];
}

- (void)arm {
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
        [self.currentTrack prepareToRecord];
    }
}

- (void)disarm {
    [self.currentTrack deleteRecording];
    self.currentTrack = nil;
}

- (void)saveRecording {
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.recordedTracksData.count inSection:0], nil] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.recordedTracksData.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)noMorePendingTrackCell {
    self.pendingSaveTrackCell.pendingSave = NO;
    [self.pendingSaveTrackCell.cancelButton removeTarget:self action:@selector(onCancelRecording:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendingSaveTrackCell.saveButton removeTarget:self action:@selector(onSaveRecording:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.pendingSaveTrackCell = nil;
}

# pragma Playback Manager Delegate

- (void)playbackManagerDidFinishPlaying:(PlaybackManager *)manager {
    [self stopPlaying];
    
    if (self.state != kRecording) {
        if (self.state == kPlaying) {
            self.state = kIdle;
        }
        else if (self.state == kPreviewing) {
            self.state = kPendingSave;
        }
    }
}

- (void)playbackManagerScrubberDidMove:(PlaybackManager *)manager {
    float targetValue = self.playbackManager.scrubberPosition / self.playbackManager.songLength;
    if (self.scrubberBar.value != targetValue) {
        self.scrubberBar.value = targetValue;
    }
}

#pragma Table View Delegate

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
    return self.state == kPendingSave ? self.recordedTracksData.count : self.recordedTracksData.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIViewController *tempViewController;
    
    if (indexPath.row == self.recordedTracksData.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewTrackView" forIndexPath:indexPath];
        self.createNewTrackView = (NewTrackView *)cell;
        
        if (cell == nil) {
            tempViewController = [[UIViewController alloc] initWithNibName:@"NewTrackView" bundle:nil];
            self.createNewTrackView = (NewTrackView *)tempViewController.view;
            cell = self.createNewTrackView;
            
        }
        
        [self.createNewTrackView.recordButton addTarget:self action:@selector(onRecord:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.createNewTrackView.cancelButton addTarget:self action:@selector(onCancelRecording:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        NSManagedObject *data = [self.recordedTracksData objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"RecordedTrackView" forIndexPath:indexPath];
        RecordedTrackCell *recordedTrack = (RecordedTrackCell *)cell;
        
        if (cell == nil) {
            recordedTrack = (RecordedTrackCell *)[[UIViewController alloc] initWithNibName:@"RecordedTrackView" bundle:nil];
            cell = (RecordedTrackCell *)recordedTrack;
        }
        
        recordedTrack.trackLabel.text = [data valueForKey:@"name"];
        recordedTrack.muteSwitch.on = ![[data valueForKey:@"muted"] boolValue];
        recordedTrack.volumeSlider.value = [[data valueForKey:@"volume"] floatValue];
        recordedTrack.muteSwitch.tag = indexPath.row;
        recordedTrack.volumeSlider.tag = indexPath.row;
        recordedTrack.pendingSave = NO;
        [recordedTrack.muteSwitch addTarget:self action:@selector(onMute:forEvent:) forControlEvents:UIControlEventValueChanged];
        [recordedTrack.volumeSlider addTarget:self action:@selector(onAdjustVolume:forEvent:) forControlEvents:UIControlEventValueChanged];
        
        if (indexPath.row == self.recordedTracksData.count - 1 && self.state == kPendingSave) {
            [self noMorePendingTrackCell];
            recordedTrack.pendingSave = YES;
            [recordedTrack.cancelButton addTarget:self action:@selector(onCancelRecording:forEvent:) forControlEvents:UIControlEventTouchUpInside];
            [recordedTrack.saveButton addTarget:self action:@selector(onSaveRecording:forEvent:) forControlEvents:UIControlEventTouchUpInside];
            self.pendingSaveTrackCell = recordedTrack;
        }
    }
    
    return cell;
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

#pragma Getters and Setters

- (void)setState:(int)state {
    if (_state != state) {
        _state = state;
        self.createNewTrackView.state = state;
    }
}

@end
