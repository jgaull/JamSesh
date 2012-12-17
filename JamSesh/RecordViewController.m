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

@interface RecordViewController ()

@property (nonatomic) int state;

@property (strong, nonatomic) NSDictionary *recordSettings;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSMutableArray *audioPlayers;
@property (strong, nonatomic) AVAudioRecorder *currentTrack;

@property (nonatomic) int numCompletedTracks;
@property (nonatomic) int numUnmutedTracks;

@property (strong, nonatomic) NSMutableArray *recordedTracksData;

@property (weak, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@end

@interface RecordViewController ()

@end

@implementation RecordViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //create data and fill it up here. Will probably have to load tracks from storage.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrackModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.recordedTracksData = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    
    for (NSManagedObject *trackData in self.recordedTracksData) {
        [self addTrack:trackData];
    }
    
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
    [self readyRecordingTrack];
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
    return self.recordedTracksData.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIViewController *tempViewController;
    
    if (indexPath.row == self.recordedTracksData.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewTrackView" forIndexPath:indexPath];
        NewTrackView *newTrack = (NewTrackView *)cell;
        
        if (cell == nil) {
            tempViewController = [[UIViewController alloc] initWithNibName:@"NewTrackView" bundle:nil];
            newTrack = (NewTrackView *)tempViewController.view;
            cell = newTrack;
            
        }
        
        [newTrack.recordButton addTarget:self action:@selector(onRecord:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        self.recordButton = newTrack.recordButton;
        
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
        recordedTrack.muteSwitch.tag = indexPath.row;
        [recordedTrack.muteSwitch addTarget:self action:@selector(onMute:forEvent:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark - Button Listeners

- (void)onRecord:(id)sender forEvent:(UIEvent *)event {
    if (self.state == kIdle) {
        [self recordAudio];
    }
    else if (self.state == kRecording) {
        [self stop];
    }
}

- (IBAction)onPlay:(id)sender {
    if (self.state == kPlaying) {
        [self stop];
    }
    else if (self.state == kIdle) {
        [self playAudio];
    }
}

- (void)onMute:(UISwitch *)sender forEvent:(UIEvent *)event {
    NSManagedObject *data = [self.recordedTracksData objectAtIndex:sender.tag];
    [data setValue:[NSNumber numberWithBool:!sender.on] forKey:@"muted"];
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Oops. Error saving your muting of the track duder: %@", [error localizedDescription]);
    }
    
    if (!sender.on) {
        self.numUnmutedTracks--;
    }
    else {
        self.numUnmutedTracks++;
    }
}


#pragma mark - the magic

-(void)recordAudio
{
    [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.currentTrack record];
    //[self playAllRecordedTracks];
    self.state = kRecording;
}

-(void)stop
{
    if (self.state == kRecording)
    {
        [self.currentTrack stop];
        [self stopPlayingAllRecordedTracks];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        
        //write the info about the new track to the database
        NSManagedObjectContext *context = self.managedObjectContext;
        NSManagedObject *trackModel = [NSEntityDescription insertNewObjectForEntityForName:@"TrackModel" inManagedObjectContext:context];
        [trackModel setValue:self.currentTrack.url.filePathURL.path forKey:@"fileURL"];
        [trackModel setValue:self.currentTrack.url.filePathURL.path forKey:@"name"];
        [trackModel setValue:self.currentTrack.url.filePathURL.lastPathComponent forKey:@"id"];
        NSError *error = nil;
        
        if (![context save:&error]) {
            NSLog(@"Coulnd't save track! %@", [error localizedDescription]);
        }
        
        [self.recordedTracksData addObject:trackModel];
        [self addTrack:trackModel];
        [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationRight];
        [self readyRecordingTrack];
    }
    else if (self.state == kPlaying)
    {
        [self stopPlayingAllRecordedTracks];
        self.recordButton.enabled = YES;
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    self.state = kIdle;
}

-(void)playAudio
{
    if (self.numUnmutedTracks > 0) {
        self.recordButton.enabled = NO;
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self playAllRecordedTracks];
        self.state = kPlaying;
    }
}

- (void)playAllRecordedTracks
{
    for (int i = 0; i < self.audioPlayers.count; i++) {
        NSManagedObject *data = [self.recordedTracksData objectAtIndex:i];
        AVAudioPlayer *player = [self.audioPlayers objectAtIndex:i];
        BOOL muted = [[data valueForKey:@"muted"] boolValue];
        
        if (!muted) {
            [player play];
        }
    }
}

- (void)stopPlayingAllRecordedTracks
{
    for (AVAudioPlayer *player in self.audioPlayers) {
        [player stop];
        player.currentTime = 0;
    }
}

- (void)addTrack:(NSManagedObject *)trackData {
    if (self.audioPlayers == nil) {
        self.audioPlayers = [[NSMutableArray alloc] init];
    }
    
    NSError *error = nil;
    NSURL *trackUrl = [NSURL fileURLWithPath:[trackData valueForKey:@"fileURL"]];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:trackUrl error:&error];
    
    if (error) {
        NSLog(@"Error loading audio player: %@", [error localizedDescription]);
    }
    else
    {
        player.delegate = self;
        [player prepareToPlay];
        [self.audioPlayers addObject:player];
        
        if (![[trackData valueForKey:@"muted"] boolValue]) {
            self.numUnmutedTracks++;
        }
    }
}

- (void)readyRecordingTrack {
    NSString *soundFilePath = [self.basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"track%d.caf", self.recordedTracksData.count]];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.numCompletedTracks++;
    
    if (self.numCompletedTracks == self.numUnmutedTracks) {
        self.numCompletedTracks = 0;
        [self stop];
    }
}

#pragma mark - Table view delegate

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
