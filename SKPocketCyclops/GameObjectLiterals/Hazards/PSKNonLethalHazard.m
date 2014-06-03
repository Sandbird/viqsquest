//
//  PSKNonLethalHazard.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/12/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKNonLethalHazard.h"

@implementation PSKNonLethalHazard

- (id)initWithRect:(CGRect)rect {
    if ((self = [super init])) {
        // upon creation, store the rectangle into
        // self.hazardRect
        self.hazardRect = rect;
    }
    
    return self;
}

@end
