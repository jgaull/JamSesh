//
//  RecordViewController.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import "RecordViewController.h"
#import "NewTrackView.h"

@interface RecordViewController ()

@property (nonatomic) int state;

@property (strong, nonatomic) NSDictionary *recordSettings;
@property (strong, nonatomic) NSString *basePath;
@property (strong, nonatomic) NSMutableArray *audioTracks;
@property (strong, nonatomic) NSMutableArray *audioPlayers;
@property (strong, nonatomic) AVAudioRecorder *currentTrack;

@end

@interface RecordViewController ()

@end

@implementation RecordViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
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
    
    if (indexPath.row == self.audioTracks.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewTrackView" forIndexPath:indexPath];
        NewTrackView *theView = (NewTrackView *)cell;
        
        if (cell == nil) {
            UIViewController *tempViewController = [[UIViewController alloc] initWithNibName:@"NewTrackView" bundle:nil];
            theView = (NewTrackView *)tempViewController.view;
            cell = theView;
            
        }
        
        [theView.playButton addTarget:self action:@selector(onPlay:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        [theView.recordButton addTarget:self action:@selector(onRecord:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    // Configure the cell...
    
    return cell;
}
             
- (void)onPlay:(id)sender forEvent:(UIEvent *)event {
    
    NSLog(@"Play");
    
}

- (void)onRecord:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"Record");
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
