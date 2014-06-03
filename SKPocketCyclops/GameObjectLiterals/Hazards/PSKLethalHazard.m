//
//  PSKLethalHazard.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/12/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKLethalHazard.h"

@implementation PSKLethalHazard

- (id)initWithRect:(CGRect)rect {
    if ((self = [super init])) {
        // upon creation, store the rectangle into
        // self.hazardRect
        self.hazardRect = rect;
    }
    
    return self;
}

@end
