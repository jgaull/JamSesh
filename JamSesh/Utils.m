//
//  Utils.m
//  JamSesh
//
//  Created by Jonathan Gaull on 12/23/12.
//  Copyright (c) 2012 Jonathan Gaull. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(NSDictionary*)createTimemapForSeconds:(NSTimeInterval)interval {

    long time = (long)interval; // convert to long, NSTimeInterval is *some* numeric type
    
    long hundreths = (time * 100) % 100;
    long seconds = time % 60;   // remainder is seconds
    time /= 60;                 // total number of mins
    long minutes = time % 60;   // remainder is minutes
    long hours = time / 60;      // number of hours
    
    NSDictionary * timeMap = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:hours], [NSNumber numberWithInt:minutes], [NSNumber numberWithInt:seconds], [NSNumber numberWithInt:hundreths], nil] forKeys:[NSArray arrayWithObjects:@"h", @"m", @"s", @"hundreths", nil]];
    
    return timeMap;
}

@end
