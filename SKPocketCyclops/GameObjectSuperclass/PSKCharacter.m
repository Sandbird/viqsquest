//
//  PSKCharacter.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKCharacter.h"

@implementation PSKCharacter

- (void)update:(NSTimeInterval)dt {
    // silence warning
}

- (id)initWithTexture:(SKTexture *)texture {
    if ((self = [super initWithTexture:texture])) {
        
    }
    
    return self;
}

- (CGRect)collisionBoundingBox {
    // calculate movement and apply to rect
    CGPoint diff = CGPointSubtract(self.desiredPosition, self.position);
    return CGRectOffset(self.frame, diff.x, diff.y);
}

- (void)changeState:(CharacterState)newState {
    // override in subclasses
}

- (void)tookHit:(PSKCharacter *)character {
    // took hit
}

@end
