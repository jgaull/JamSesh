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

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    self.editingTextField.delegate = self;
}

#pragma mark - Event Listeners

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

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [self.editingTextField resignFirstResponder];
        
        if ([self.delegate respondsToSelector:@selector(recordedTrackCellUserDidRename:name:)]) {
            [self.delegate recordedTrackCellUserDidRename:self name:self.editingTextField.text];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(recordedTrackCellUserDidBeginEditingName:)]) {
        //The keyboard needs to start popping up before this method is called so that the table can scroll to the correct position.
        [self.delegate performSelector:@selector(recordedTrackCellUserDidBeginEditingName:) withObject:self afterDelay:0.001];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(recordedTrackCellUserDidRename:name:)]) {
        [self.delegate recordedTrackCellUserDidRename:self name:self.editingTextField.text];
    }
}

#pragma mark - Getters and Setters

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.trackLabel.hidden = editing;
    self.muteSwitch.hidden = editing;
    self.volumeSlider.hidden = editing;
    self.editingTextField.hidden = !editing;
    
    if (editing) {
        self.editingTextField.text = self.trackLabel.text;
    }
    else if (super.editing) {
        if ([self.delegate respondsToSelector:@selector(recordedTrackCellUserDidRename:name:)]) {
            [self.delegate recordedTrackCellUserDidRename:self name:self.editingTextField.text];
        }
        
        [self.editingTextField resignFirstResponder];
    }
    
    [super setEditing:editing animated:animated];
}

- (void)setPendingSave:(BOOL)pendingSave {
    self.trackLabel.hidden = pendingSave;
    self.cancelButton.hidden = !pendingSave;
    self.saveButton.hidden = !pendingSave;
}

@end
