//
//  PSKTurret.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/1/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKTurret.h"
#import "PSKArrow.h"

#import "PSKSharedTextureCache.h"

@interface PSKTurret () {
    // time till can next fire
    int timeTillNextDecision;
}

@end

@implementation PSKTurret

- (id)initWithTexture:(SKTexture *)name {
    if (self = [super initWithTexture:name]) {
        // set life to 200, and activate it
        self.life = 200;
        self.isActive = YES;
        
        // set an intiial time till next decision
        timeTillNextDecision = 60;
        
        // create the arm and set the anchor point (point of rotation)
        SKTextureAtlas *atlas = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
        self.arm = [[SKSpriteNode alloc] initWithTexture:[atlas textureNamed:@"PSKTurrentArm1"]];
        self.arm.anchorPoint = CGPointMake(1, 0.5);
        self.arm.position = CGPointMake(self.position.x, self.position.y);
        [self addChild:self.arm];
        
        // setup dying animation
        self.dyingAnim = [self loadAnimationFromPlist:@"dyingAnim" forClass:@"PSKTurret"];
    }
    
    return self;
}

- (CGRect)collisionBoundingBox {
    // return self's frame
    return self.frame;
}

- (void)update:(NSTimeInterval)dt {
    // if distance is within 350 pixels, else don't animate
    // this is to prevent random memory consumption
    if (CGPointDistance(self.position, self.player.position) < 350) {
        if (self.isGroundMounted) {
            // if it is mounted on the ground. rotate the arm to face the player
            CGPoint diff = CGPointSubtract(self.player.position,self.position);
            float angleRadians = atanf((float)diff.y / (float)diff.x);
            if (diff.x > 0) {
                angleRadians -= 3.14;
            }
            
            // force the arm to only rotate in geometrically between 0 and PI
            // assuming that 0 is the positive x-axis and rotating counter-clockwise
            if ((angleRadians <= 0.25 && angleRadians >= -3.14)) {
                self.arm.zRotation = angleRadians;
            }
        }
        
        // if can make a decision. spin a random number % 2, and if it is 0 (50%), fire an arrow
        timeTillNextDecision--;
        if (timeTillNextDecision <= 0) {
            if (arc4random() % 2 == 0) {
                if ([self.delegate respondsToSelector:@selector(firedTurret:)]) {
                    [self.delegate firedTurret:self];
                }
            }
            
            // reset time
            timeTillNextDecision = 60;
        }
    }
}

- (void)changeState:(CharacterState)newState {
    if (newState == self.characterState) return;
    [self removeAllActions];
    self.characterState = newState;
    
    SKAction *action = nil;
    switch (newState) {
        // if the state is dead, remove the arm and run the dying animation
        case kStateDead: {
            [self.arm removeFromParent];
            self.arm = nil;
            
            action = [SKAction sequence:@[self.dyingAnim,[SKAction performSelector:@selector(removeSelf) onTarget:self]]];
            break;
        }
        default:
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

@end
