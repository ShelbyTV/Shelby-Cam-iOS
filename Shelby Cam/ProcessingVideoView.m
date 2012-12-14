//
//  ProcessingVideoView.m
//  Shelby Cam
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "ProcessingVideoView.h"

@implementation ProcessingVideoView
@synthesize indicator = _indicator;

- (void)dealloc
{
    self.indicator = nil;
}

- (void)awakeFromNib
{
    
}

@end