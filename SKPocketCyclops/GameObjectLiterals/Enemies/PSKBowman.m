//
//  PSKBowman.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/5/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKBowman.h"
#import "PSKSharedTextureCache.h"

@interface PSKBowman () {
    int timeTillNextDecision;
}

@end

@implementation PSKBowman

- (id)initWithTexture:(SKTexture *)name {
    if (self = [super initWithTexture:name]) {
        // setup life + active and time till next decision
        self.life = 100;
        self.isActive = YES;
        
        timeTillNextDecision = 60;
        
        // create the firing arm + dying animation
        SKTextureAtlas *atlas = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
        self.arm = [[SKSpriteNode alloc] initWithTexture:[atlas textureNamed:@"PSKTurrentArm1"]];
        self.arm.anchorPoint = CGPointMake(1, 0.5);
        self.arm.position = CGPointMake(self.position.x + 15, self.position.y + 32);
        [self addChild:self.arm];
        
        self.dyingAnim = [self loadAnimationFromPlist:@"dyingAnim" forClass:@"PSKBowman"];
    }
    
    return self;
}

- (CGRect)collisionBoundingBox {
    // return self's frame
    return self.frame;
}

- (void)update:(NSTimeInterval)dt {
    // if dead don't do animation
    if (self.characterState == kStateDead)
        return;
    
    // if distance between self and player is less than 350 and player is to the left of self
    if (CGPointDistance(self.position, self.player.position) < 350) {
        if (self.player.position.x >= self.position.x)
            return;
        
        // adjust the arm's rotation to match up in a straight line at that moment
        CGPoint diff = CGPointSubtract(self.player.position,self.position);
        float angleRadians = atanf((float)diff.y / (float)diff.x);
        if (diff.x > 0) {
            angleRadians -= 3.14;
        }
        // limit arm's rotation to be only between 0 and PI_2, 0 is negative x-axis
        if ((angleRadians <= 0.25 && angleRadians >= -1.57)) {
            self.arm.zRotation = angleRadians;
        }
        
        // if can fire, bowman Fired delegate method and reset time
        timeTillNextDecision--;
        if (timeTillNextDecision <= 0) {
            if (arc4random() % 2 == 0) {
                if ([self.delegate respondsToSelector:@selector(bowmanFired:)]) {
                    [self.delegate bowmanFired:self];
                }
            }
            
            timeTillNextDecision = 60;
        }
    }
}

// if dead, remove arm and run the dying animation
- (void)changeState:(CharacterState)newState {
    if (newState == self.characterState) return;
    [self removeAllActions];
    self.characterState = newState;
    
    SKAction *action = nil;
    switch (newState) {
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
