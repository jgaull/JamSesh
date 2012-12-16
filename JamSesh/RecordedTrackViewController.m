//
//  RecordedTrackViewController.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "RecordedTrackViewController.h"

@interface RecordedTrackViewController ()

@property (strong, nonatomic) IBOutlet UILabel *trackLabel;
@property (strong, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;

@end

@implementation RecordedTrackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setData:(NSManagedObject *)data {
    self.data = data;
    
    //self.muteSwitch.on = (BOOL)[data valueForKey:@"muted"];
    //self.volumeSlider.value = (float)[data valueForKey:@"gain"];
    self.trackLabel.text = (NSString *)[data valueForKey:@"name"];
}

- (IBAction)onMuteValueChanged:(id)sender {
}

- (IBAction)onVolumeValueChanged:(id)sender {
}

@end
