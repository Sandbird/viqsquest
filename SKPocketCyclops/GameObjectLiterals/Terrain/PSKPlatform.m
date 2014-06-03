//
//  PSKPlatform.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/8/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKPlatform.h"
#import "SKTUtils.h"

@interface PSKPlatform ()

@property (nonatomic, assign) CGPoint previousPos;

@end

@implementation PSKPlatform

- (id)initWithImageNamed:(SKTexture *)name forPlatformType:(NSString*)pT withSpeed:(CGFloat)speed andDistance:(CGFloat)dTM {
    if (self = [super initWithTexture:name]) {
        SKAction* sequence;
        // if horizontal, create two actions to move it horizontally (back and forth) and chain them together
        if ([pT isEqualToString:@"horizontal"]) {
            SKAction* moveRight = [SKAction moveByX:dTM y:0.0 duration:speed];
            SKAction* moveLeft = [SKAction moveByX:-dTM y:0.0 duration:speed];
            sequence = [SKAction sequence:@[moveRight,moveLeft]];
        } else {
        // if vertical, create two actions to move it vertically (up and down) and chain them together
            SKAction* moveDown = [SKAction moveByX:0.0 y:dTM duration:speed];
            SKAction* moveUp = [SKAction moveByX:0.0 y:dTM duration:speed];
            sequence = [SKAction sequence:@[moveDown,moveUp]];
        }
        
        // repeat action forever
        [self runAction:[SKAction repeatActionForever:sequence]];
    }
    
    return self;
}

// get the collision rectangle
- (CGRect)collisionBoundingBox {
    CGRect bounding = self.frame;
    return CGRectOffset(bounding, 0, -3);
}

// update velocity and the previous position
- (void)update:(NSTimeInterval)dt {
    CGPoint currentPos = self.position;
    self.velocity = CGPointSubtract(currentPos,self.previousPos);
    self.previousPos = currentPos;
}

@end
