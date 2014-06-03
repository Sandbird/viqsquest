//
//  SlopeObject.m
//  Vic's Quest
//
//  Created by William Zhang on 5/26/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "SlopeObject.h"

@implementation SlopeObject

- (id)initWithRect:(CGRect)rect up:(BOOL)isUp {
    if ((self = [super init])) {
        self.rect = rect;
        self.isUp = isUp;
    }
    
    return self;
}

@end
