//
//  PSKHound.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/5/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#define kHoundWidth 64
#define kHoundHeight 32

#import "PSKHound.h"

@interface PSKHound ()

@property (nonatomic, strong) SKAction *seekingAnim;
@property (nonatomic, strong) SKAction *attackingAnim;
@property (nonatomic, strong) SKAction *lookingAnim;

@end

@implementation PSKHound

- (id)initWithTexture:(SKTexture *)name {
    if ((self = [super initWithTexture:name])) {
        // create all necessary animations
        self.dyingAnim = [self loadAnimationFromPlist:@"dyingAnim" forClass:@"PSKHound"];
        self.seekingAnim = [self loadAnimationFromPlist:@"seekingAnim" forClass:@"PSKHound"];
        self.attackingAnim = [self loadAnimationFromPlist:@"attackingAnim" forClass:@"PSKHound"];
        self.lookingAnim = [self loadAnimationFromPlist:@"lookingAnim" forClass:@"PSKHound"];
    }
    
    return self;
}

- (void)update:(NSTimeInterval)dt {
    // if dead, return
    if (self.characterState == kStateDead) {
        self.desiredPosition = self.position;
        return;
    }
    
    // if distance is greater than 350 return
    CGFloat distance = CGPointDistance(self.position, self.player.position);
    if (distance > 350) {
        self.desiredPosition = self.position;
        self.isActive = NO;
        return;
    } else
        self.isActive = YES;
    
    // depending on the distance, set the correct state, and the correct speed
    CGFloat speed;
    if (distance < 128) {
        // within attacking distance!
        [self changeState:kStateAttacking];
        speed = 100;
    } else if ((!self.player.flipX && self.flipX &&  self.player.position.x < self.position.x) ||
               (self.player.flipX && !self.flipX && self.player.position.x > self.position.x)) {
        // if the player is looking at the enemy and enemy is looking at player
        [self changeState:kStateSeeking];
        speed = 70;
    } else {
        // not looking
        [self changeState:kStateHiding];
        speed = 30;
    }
    
    if (self.onGround) {
        // if on ground, use flipx property to determine direction
        if (self.flipX) {
            self.velocity = CGPointMake(-speed, 0);
        } else {
            self.velocity = CGPointMake(speed, 0);
        }
    } else {
        // otherwise it is falling vertically
        self.velocity = CGPointMake(self.velocity.x * 0.98, self.velocity.y);
    }
    
    if (self.onWall) {
        // if it is on the wall, reverse direction and set flipx
        self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
        if (self.velocity.x > 0) {
            self.flipX = NO;
        } else {
            self.flipX = YES;
        }
    }
    
    CGPoint gravity = CGPointMake(0.0, -450.0);
    CGPoint gravityStep = CGPointMultiplyScalar(gravity, dt);
    
    self.velocity = CGPointAdd(self.velocity, gravityStep);
    self.desiredPosition = CGPointAdd(self.position, CGPointMultiplyScalar(self.velocity, dt));
}

// state change, run a different animation depending on the states
- (void)changeState:(CharacterState)newState {
    if (newState == self.characterState) return;
    [self removeAllActions];
    self.characterState = newState;
    
    SKAction *action = nil;
    switch (newState) {
        case kStateSeeking: {
            action = [SKAction repeatActionForever:self.seekingAnim];
            break;
        }
        case kStateHiding: {
            action = [SKAction repeatActionForever:self.lookingAnim];
            break;
        }
        case kStateAttacking: {
            action = [SKAction repeatActionForever:self.attackingAnim];
            break;
        }
        case kStateDead: {
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

// collision bounding box
- (CGRect)collisionBoundingBox {
    return CGRectMake(self.desiredPosition.x - (kHoundWidth/2), self.desiredPosition.y - (kHoundHeight/2),
                      kHoundWidth, kHoundHeight);
}

@end
