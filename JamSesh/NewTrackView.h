//
//  NewTrackView.h
//  JamSesh
//
//  Created by Jonathan Gaull on 12/15/12.
//  Copyright (c) 2012 OneHeadedLlama. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewTrackViewDelegate;

@interface NewTrackView : UITableViewCell

@property (weak, nonatomic) NSObject <NewTrackViewDelegate> *delegate;

@end

@protocol NewTrackViewDelegate <NSObject>

- (BOOL)newTrackViewShouldBeginRecording:(NewTrackView *)newTrackView;
- (BOOL)newTrackViewShouldArmForRecording:(NewTrackView *)newTrackView;

@optional

- (void)newTrackViewDisarm:(NewTrackView *)newTrackView;
- (void)newTrackViewEndRecording:(NewTrackView *)newTrackView;

@end