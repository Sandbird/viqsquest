//
//  PSKCharacter.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKTUtils.h"
#import "PSKGameObject.h"

@interface PSKCharacter : PSKGameObject

typedef NS_ENUM(NSInteger, CharacterState) {
    // player states
    kStateJumping,
    kStateDoubleJumping,
    kStateWalking,
    kStateStanding,
    kStateFalling,
    kStateDead,
    kStateWallSliding,
    // enemie states
    kStateAttacking,
    kStateSeeking,
    kStateHiding
};

// character state holder and changer
@property (nonatomic, assign) CharacterState characterState;
- (void)changeState:(CharacterState)newState;

// velocity
@property (nonatomic, assign) CGPoint velocity;

// desired position
@property (nonatomic, assign) CGPoint desiredPosition;

// isactive (can damage/be damaged) & life & dying animation
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) NSInteger life;
@property (nonatomic, strong) SKAction *dyingAnim;

// is on platform?
@property (nonatomic, assign) BOOL onPlatform;

// take hit
- (void)tookHit:(PSKCharacter *)character;

// update position
- (void)update:(NSTimeInterval)dt;

// bounding box collision
- (CGRect)collisionBoundingBox;

// is on the ground / wall
@property (nonatomic, assign) BOOL onGround;
@property (nonatomic, assign) BOOL onWall;

@end
