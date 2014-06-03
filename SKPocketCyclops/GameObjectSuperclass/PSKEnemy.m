//
//  PSKEnemy.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/14/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKEnemy.h"

@implementation PSKEnemy

// initialize
- (id)initWithTexture:(SKTexture *)name {
    if (self = [super initWithTexture:name]) {
        
    }
    
    return self;
}

// took hit
- (void)tookHit:(PSKCharacter *)character {
    self.life = self.life - 100;
    if (self.life <= 0) {
        // if no life, set state to dead
        self.isActive = NO;
        [self changeState:kStateDead];
    }
}

// set isactive to no so will not interrupt, will be removed in update:
- (void)removeSelf {
    self.isActive = NO;
}

@end
