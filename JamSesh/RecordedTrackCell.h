//
//  RecordedTrackCell.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol RecordedTrackCellDelegate;

@interface RecordedTrackCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) NSObject <RecordedTrackCellDelegate> *delegate;
@property (nonatomic) BOOL pendingSave;
@property (nonatomic, strong) NSManagedObjectID *trackId;

@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (strong, nonatomic) IBOutlet UILabel *trackLabel;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;

@end

@protocol RecordedTrackCellDelegate <NSObject>
@optional

- (void)recordedTrackCellVolumeDidChange:(RecordedTrackCell *)cell value:(float)value;
- (void)recordedTrackCellMuteDidChange:(RecordedTrackCell *)cell value:(BOOL)value;
- (void)recordedTrackCellUserDidSave:(RecordedTrackCell *)cell;
- (void)recordedTrackCellUserDidCancel:(RecordedTrackCell *)cell;
- (void)recordedTrackCellUserDidRename:(RecordedTrackCell *)cell name:(NSString *)name;
- (void)recordedTrackCellUserDidBeginEditingName:(RecordedTrackCell *)cell;

@end
