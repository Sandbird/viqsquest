//
//  PSKDog.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/5/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKGB.h"
#import "PSKSharedTextureCache.h"

#define kCrawlerWidth 32
#define kCrawlerHeight 32

#define kMovementSpeed 60

@interface PSKGB ()

@property (nonatomic, strong) SKTexture *initialTexture;

@property (nonatomic, strong) SKAction *dyingAnim;
@property (nonatomic, strong) SKAction *walkingAnim;

@end

@implementation PSKGB

- (id)initWithTexture:(SKTexture *)name {
    if (self = [super initWithTexture:name]) {
        // store reference to initial texture and load animations from plist
        self.initialTexture = name;
        
        self.walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" forClass:@"PSKGB"];
        self.dyingAnim = [self loadAnimationFromPlist:@"dyingAnim" forClass:@"PSKGB"];
    }
    
    return self;
}

- (void)update:(NSTimeInterval)dt {
    // if state is dead, return
    if (self.characterState == kStateDead) {
        self.desiredPosition = self.position;
        return;
    }
    
    // if distance is greater than 350, return
    CGFloat distance = CGPointDistance(self.position, self.player.position);
    if (distance > 350) {
        self.desiredPosition = self.position;
        self.isActive = NO;
        return;
    } else
        self.isActive = YES;
    
    if (self.onGround) {
        [self changeState:kStateWalking];
        
        // if on ground, use flipx property to determine direction
        if (self.flipX) {
            self.velocity = CGPointMake(-kMovementSpeed, 0);
        } else {
            self.velocity = CGPointMake(kMovementSpeed, 0);
        }
    } else {
        [self changeState:kStateFalling];
        
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

- (CGRect)collisionBoundingBox {
    // return collision rectangle
    return CGRectMake(self.desiredPosition.x - (kCrawlerWidth/2), self.desiredPosition.y - (kCrawlerHeight/2),
                      kCrawlerWidth, kCrawlerHeight);
}

// depending on state, update accordingly
- (void)changeState:(CharacterState)newState {
    if (newState == self.characterState) return;
    [self removeAllActions];
    self.characterState = newState;
    
    SKAction *action = nil;
    switch (newState) {
        case kStateWalking: {
            action = [SKAction repeatActionForever:self.walkingAnim];
            break;
        }
        case kStateFalling: {
            [self setTexture:self.initialTexture];
            [self setSize:self.texture.size];
            return;
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

@end