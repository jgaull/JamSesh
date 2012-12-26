//
//  RecordedTrackCell.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordedTrackCellDelegate;

@interface RecordedTrackCell : UITableViewCell

@property (nonatomic, weak) NSObject <RecordedTrackCellDelegate> *delegate;
@property (nonatomic) BOOL pendingSave;

@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (strong, nonatomic) IBOutlet UILabel *trackLabel;

@end

@protocol RecordedTrackCellDelegate <NSObject>
@optional

- (void)recordedTrackCellVolumeDidChange:(RecordedTrackCell *)cell value:(float)value;
- (void)recordedTrackCellMuteDidChange:(RecordedTrackCell *)cell value:(BOOL)value;
- (void)recordedTrackCellUserDidSave:(RecordedTrackCell *)cell;
- (void)recordedTrackCellUserDidCancel:(RecordedTrackCell *)cell;

@end
