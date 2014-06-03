//
//  PSKKnight.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/5/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKKnight.h"
#import "PSKSharedTextureCache.h"

// define some constants
#define kKnightWidth 32
#define kKnightHeight 64
#define kCoweringHeight 32
#define kMovementSpeed 60

@interface PSKKnight ()

// maintain reference to heal time, walking animation
@property (nonatomic, strong) SKAction *walkingAnim;
@property (nonatomic) int healTime;

// reference default and cowering texture
@property (nonatomic, strong) SKTexture *defaultTexture;
@property (nonatomic, strong) SKTexture *coweringTexture;

@end

@implementation PSKKnight

- (id)initWithTexture:(SKTexture *)name {
    if (self = [super initWithTexture:name]) {
        // set life to 200, set iscowering to NO
        self.life = 200;
        self.isCowering = NO;
        
        // set an heal time, runs off of the FPS
        self.healTime = 120;
        
        // retrieve necessary textures and setup animations
        SKTextureAtlas *a = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
        self.defaultTexture = name;
        self.coweringTexture = [a textureNamed:@"PSKKnightHiding1.png"];
        
        self.walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" forClass:@"PSKKnight"];
        self.dyingAnim = [self loadAnimationFromPlist:@"dyingAnim" forClass:@"PSKKnight"];
    }
    
    return self;
}

- (void)update:(NSTimeInterval)dt {
    // if dead, don't update
    if (self.characterState == kStateDead) {
        self.desiredPosition = self.position;
        return;
    }
    
    // if distance is within 350 pixels, begin animating
    CGFloat distance = CGPointDistance(self.position, self.player.position);
    if (distance > 350) {
        self.desiredPosition = self.position;
        self.isActive = NO;
        return;
    } else
        self.isActive = YES;
    
    // if can move
    if (!self.isCowering) {
        // if on the ground, set walking state
        // use flipX to determine direction
        if (self.onGround) {
            [self changeState:kStateWalking];
            
            // if on ground, use flipx property to determine direction
            if (self.flipX) {
                self.velocity = CGPointMake(-kMovementSpeed, 0);
            } else {
                self.velocity = CGPointMake(kMovementSpeed, 0);
            }
        } else {
            // otherwise it is falling vertically
            [self changeState:kStateFalling];
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
        
        // apply the force of gravity and also calculate a scalar velocity
        // scaled to the current timestamp
        CGPoint gravity = CGPointMake(0.0, -450.0);
        CGPoint gravityStep = CGPointMultiplyScalar(gravity, dt);
        
        self.velocity = CGPointAdd(self.velocity, gravityStep);
        self.desiredPosition = CGPointAdd(self.position, CGPointMultiplyScalar(self.velocity, dt));
    } else {
        // subtract 1 from heal time. if heal time below 0
        self.healTime--;
        if (self.healTime <= 0) {
            // set not cowering
            self.isCowering = NO;
            
            // set the initial texture. size and position
            [self setSize:self.defaultTexture.size];
            [self setTexture:self.defaultTexture];
            [self setPosition:CGPointAdd(self.position, CGPointMake(0, 16))];
            
            // reset healtime and life
            self.healTime = 120;
            self.life = 200;
        }
    }
}

- (CGRect)collisionBoundingBox {
    // return different collision rectangles depending on state
    if (!self.isCowering)
        return CGRectMake(self.desiredPosition.x - (kKnightWidth/2), self.desiredPosition.y - (kKnightHeight/2),
                      kKnightWidth, kKnightHeight);
    
    return CGRectMake(self.desiredPosition.x - (kKnightWidth/2), self.desiredPosition.y - (kCoweringHeight/2),
                      kKnightWidth, kCoweringHeight);
}

- (void)changeState:(CharacterState)newState {
    if (newState == self.characterState) return;
    [self removeAllActions];
    self.characterState = newState;
    
    SKAction *action = nil;
    switch (newState) {
        // if walking, repeat walking animation forever
        case kStateWalking: {
            action = [SKAction repeatActionForever:self.walkingAnim];
            break;
        }
        // if state is dead, shift position up 16 pixels so dying animation positioning is correct
        // run the dying animation
        case kStateDead: {
            [self setPosition:CGPointAdd(self.position, CGPointMake(0, 16))];
            action = [SKAction sequence:@[self.dyingAnim,[SKAction performSelector:@selector(removeSelf) onTarget:self]]];
            break;
        }
        // set iscowering to yes
        // set the texture, size and update position
        case kStateHiding: {
            self.isCowering = YES;
            
            [self setSize:self.coweringTexture.size];
            [self setTexture:self.coweringTexture];
            
            [self setPosition:CGPointSubtract(self.position, CGPointMake(0, 16))];
            break;
        }
        default:
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

- (void)tookHit:(PSKCharacter *)character {
    // subtract 100 from life.
    // if 0, set state to dead, else set state to hiding
    self.life = self.life - 100;
    if (self.life <= 0) {
        [self changeState:kStateDead];
    }
    
    if (self.life == 100) {
        [self changeState:kStateHiding];
    }
}

@end
