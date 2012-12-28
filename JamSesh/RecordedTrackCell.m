//
//  RecordedTrackCell.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "RecordedTrackCell.h"

@interface RecordedTrackCell ()

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UITextField *editingTextField;

@end

@implementation RecordedTrackCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing {
    [super setEditing:editing];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.trackLabel.hidden = editing;
    self.editingTextField.hidden = !editing;
    
    if (editing) {
        self.editingTextField.text = self.textLabel.text;
    }
}

- (void)setPendingSave:(BOOL)pendingSave {
    self.trackLabel.hidden = pendingSave;
    self.cancelButton.hidden = !pendingSave;
    self.saveButton.hidden = !pendingSave;
}

- (IBAction)onVolumeChange:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(recordedTrackCellVolumeDidChange:value:)]) {
        [self.delegate recordedTrackCellVolumeDidChange:self value:sender.value];
    }
}

- (IBAction)onMuteChange:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(recordedTrackCellMuteDidChange:value:)]) {
        [self.delegate recordedTrackCellMuteDidChange:self value:sender.on];
    }
}

- (IBAction)onCancel:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(recordedTrackCellUserDidCancel:)]) {
        [self.delegate recordedTrackCellUserDidCancel:self];
    }
}

- (IBAction)onSave:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(recordedTrackCellUserDidSave:)]) {
        [self.delegate recordedTrackCellUserDidSave:self];
    }
}

@end
