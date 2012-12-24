//
//  RecordedTrackCell.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordedTrackCell : UITableViewCell

@property (nonatomic) BOOL pendingSave;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (strong, nonatomic) IBOutlet UILabel *trackLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@end
