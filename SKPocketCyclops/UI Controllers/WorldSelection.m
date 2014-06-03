//
//  WorldSelection.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/30/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "WorldSelection.h"

@implementation WorldSelection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // create + position the label and the button correctly
        self.worldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 161, 21)];
        [self.worldLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.worldLabel];
        
        self.selectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectionButton setFrame:CGRectMake(0, 0, 161, 161)];
        [self addSubview:self.selectionButton];
    }
    return self;
}

@end
