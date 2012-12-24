//
//  RecordedTrackCell.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/16/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "RecordedTrackCell.h"

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

- (void)setPendingSave:(BOOL)pendingSave {
    self.trackLabel.hidden = pendingSave;
    self.cancelButton.hidden = !pendingSave;
    self.saveButton.hidden = !pendingSave;
}

@end
