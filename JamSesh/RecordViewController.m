//
//  RecordViewController.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import "RecordViewController.h"
#import "NewTrackView.h"
#import "RecordedTrackView.h"

@interface RecordViewController ()

@property (nonatomic) int state;

@property (strong, nonatomic) NSDictionary *recordSettings;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSMutableArray *audioTracks;
@property (strong, nonatomic) NSMutableArray *audioPlayers;
@property (strong, nonatomic) AVAudioRecorder *currentTrack;
@property (nonatomic) int completedTracks;

@property (weak, nonatomic) UIButton *recordButton;

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewTrackView" bundle:nil] forCellReuseIdentifier:@"NewTrackView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordedTrackView" bundle:nil] forCellReuseIdentifier:@"RecordedTrackView"];
    
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
    
    self.state = kIdle;
    self.audioTracks = [[NSMutableArray alloc] init];
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
    return self.audioTracks.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIViewController *tempViewController;
    
    if (indexPath.row == self.audioTracks.count) {
        
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"RecordedTrackView" forIndexPath:indexPath];
        RecordedTrackView *recordedTrack = (RecordedTrackView *)cell;
        
        if (cell == nil) {
            tempViewController = [[UIViewController alloc] initWithNibName:@"RecordedTrackView" bundle:nil];
            recordedTrack = (RecordedTrackView *)tempViewController.view;
            cell = recordedTrack;
        }
    }
    
    // Configure the cell...
    
    return cell;
}
             
- (void)onPlay:(id)sender forEvent:(UIEvent *)event {
    if (self.state == kPlaying) {
        [self stop];
    }
    else if (self.state == kIdle) {
        [self playAudio];
    }
}

- (void)onRecord:(id)sender forEvent:(UIEvent *)event {
    if (self.state == kIdle) {
        [self recordAudio];
    }
    else if (self.state == kRecording) {
        [self stop];
    }
}

-(void) recordAudio
{
    [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    NSString *soundFilePath = [self.basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"track%d.caf", self.audioTracks.count]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSError *error = nil;
    self.currentTrack = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:self.recordSettings error:&error];
    [self.currentTrack record];
    
    [self playAllRecordedTracks];
    
    self.state = kRecording;
    
    NSLog(@"recording!");
}

-(void)stop
{
    if (self.state == kRecording)
    {
        [self.currentTrack stop];
        [self.audioTracks addObject:self.currentTrack];
        self.currentTrack = nil;
        [self stopPlayingAllRecordedTracks];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationRight];
        
        NSLog(@"stop recording!");
    }
    else if (self.state == kPlaying)
    {
        [self stopPlayingAllRecordedTracks];
        
        NSLog(@"stop playing!");
        
    }
    
    self.state = kIdle;
}

-(void) playAudio
{
    [self playAllRecordedTracks];
    self.recordButton.enabled = NO;
    self.state = kPlaying;
    NSLog(@"playing@");
}

- (void)playAllRecordedTracks
{
    self.audioPlayers = [[NSMutableArray alloc] init];
    for (AVAudioRecorder *audioTrack in self.audioTracks) {
        NSError *error = nil;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioTrack.url error:&error];
        player.delegate = self;
        [self.audioPlayers addObject:player];
        
        if (error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else
        {
            [player play];
        }
    }
}

- (void)stopPlayingAllRecordedTracks
{
    for (AVAudioPlayer *player in self.audioPlayers) {
        [player stop];
    }
    
    self.audioPlayers = nil;
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
    self.completedTracks++;
    
    if (self.completedTracks == self.audioTracks.count) {
        self.completedTracks = 0;
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
