//
//  NewTrackView.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTrackView : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *createNewTrackLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (nonatomic) int state;

@end
