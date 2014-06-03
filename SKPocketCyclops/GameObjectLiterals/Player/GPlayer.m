//
//  Player.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "GPlayer.h"

#import "SKTAudio.h"
#import "PSKSharedTextureCache.h"
#import "PSKLevelScene.h"

// declare constants for several values (self-explanatory)
#define kPlayerHeight 60
#define kPlayerWidth 30

#define kWalkingAcceleration 1600
#define kDamping 0.85

#define kJumpOut 400
#define kJumpForce 400
#define kJumpCuttoff 150
#define kWallSlideSpeed -30

#define kMaxSpeed 250

#define kKnockback 200
#define kCooldown 1.5

@interface GPlayer ()

// store if can jump
@property (nonatomic, assign) BOOL jumpReset;

// store all the animations
@property (nonatomic, strong) SKAction *walkingAnim;
@property (nonatomic, strong) SKAction *dyingAnim;
@property (nonatomic, strong) SKAction *jumpUpAnim;
@property (nonatomic, strong) SKAction *wallSlideAnim;

// store texture and the jump sound
@property (nonatomic, strong) SKTexture *initialTexture;
@property (nonatomic, strong) SKTexture *fallingTexture;

@property (nonatomic) SKAction *jumpSound;
@property (nonatomic) SKAction *playJump;
 
@end

@implementation GPlayer

- (id)initWithImageNamed:(SKTexture *)name {
    if (self = [super initWithTexture:name]) {
        // set initial veloctiy to (0,0), jumpReset and set active
        self.velocity = CGPointMake(0.0, 0.0);
        self.jumpReset = YES;
        self.isActive = YES;
        
        // set life
        self.life = 500;
        
        // store initial texture
        self.initialTexture = name;
        
        // store falling texture
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
        self.fallingTexture = [atlas textureNamed:@"Player4.png"];
        
        // create action to play jump sound
        self.playJump = [SKAction playSoundFileNamed:@"jump.mp3" waitForCompletion:NO];
        self.jumpSound = [SKAction runBlock:^{
            if (![[SKTAudio sharedInstance] isMuted])
                [self runAction:self.playJump];
        }];
        
        // read in all required animations
        self.walkingAnim = [self loadAnimationFromPlist:@"walkingAnim" forClass:@"Player"];
        self.jumpUpAnim = [self loadAnimationFromPlist:@"jumpUpAnim" forClass:@"Player"];
        self.dyingAnim = [self loadAnimationFromPlist:@"dyingAnim" forClass:@"Player"];
        self.wallSlideAnim = [self loadAnimationFromPlist:@"wallSlideAnim" forClass:@"Player"];
    }
    
    return self;
}

- (void)update:(NSTimeInterval)dt {
    // if state is dead, don't update and return
    if (self.characterState == kStateDead) {
        self.desiredPosition = self.position;
        return;
    }
    
    // if on platform, reset ability to jump
    if (self.onPlatform || self.onSlope) {
        self.jumpReset = YES;
    }
    
    // set initial state
    CharacterState newState = self.characterState;
    
    // calculate left/right position to add depending on state of left/right button
    CGPoint joyForce = CGPointZero;
    if (self.hud.joyDirection == kJoyDirectionLeft) {
        self.flipX = YES;
        joyForce = CGPointMake(-kWalkingAcceleration, 0);
    } else if (self.hud.joyDirection == kJoyDirectionRight) {
        self.flipX = NO;
        joyForce = CGPointMake(kWalkingAcceleration, 0);
    }
    
    CGPoint joyForceStep = CGPointMultiplyScalar(joyForce, dt);
    self.velocity = CGPointAdd(self.velocity, joyForceStep);
    
    // calculate jump force
    if (self.hud.jumpState == kJumpButtonOn) {
        // if state is jumping/falling and can jump, jump again and set the reset to NO and state to DoubleJump
        if ((self.characterState == kStateJumping || self.characterState == kStateFalling) && self.jumpReset) {
            self.velocity = CGPointMake(self.velocity.x, kJumpForce);
            self.jumpReset = NO;
            newState = kStateDoubleJumping;
        } else if (((self.onGround || self.onPlatform || self.onSlope) || self.characterState == kStateWallSliding) && self.jumpReset) {
            // if on the ground/platform or is wall sliding and can jump
            // jump, set the reset to NO
            self.velocity = CGPointMake(self.velocity.x, kJumpForce);
            self.jumpReset = NO;
            
            // if wall sliding, set flipx accordingly and also apply jump outside
            if (self.characterState == kStateWallSliding) {
                NSInteger direction = 1;
                if (self.flipX)
                    direction = 1;
                
                self.velocity = CGPointMake(direction * kJumpOut, self.velocity.y);
            }
            
            // set state to jumping, onGround and onPlatform
            newState = kStateJumping;
            self.onGround = NO;
            self.onPlatform = NO;
        }
    } else {
        // (cutoff jump) not pressing jump button long enough
        if (self.velocity.y > kJumpCuttoff) {
            self.velocity = CGPointMake(self.velocity.x, kJumpCuttoff);
        }
        
        self.jumpReset = YES;
    }
    
    // set the correct states depending on factors
    if ((self.onGround || self.onPlatform || self.onSlope) && self.hud.joyDirection == kJoyDirectionNone) {
        newState = kStateStanding;
    } else if ((self.onGround || self.onPlatform || self.onSlope) && self.hud.joyDirection != kJoyDirectionNone) {
        newState = kStateWalking;
    } else if (self.onWall && self.velocity.y < 0) {
        newState = kStateWallSliding;
    } else if (self.characterState == kStateDoubleJumping || newState == kStateDoubleJumping) {
        newState = kStateDoubleJumping;
    } else if (self.characterState == kStateJumping || newState == kStateJumping) {
        newState = kStateJumping;
    } else {
        newState = kStateFalling;
    }
    
    // change the state
    [self changeState:newState];
    
    // if (self.onSlope) {
        // accelerate downwards ( gravity )
        CGPoint gravity = CGPointMake(0.0, -450.0);
        // transform gravity into a step value
        CGPoint gravityStep = CGPointMultiplyScalar(gravity, dt);
        
        // add gravity to current velocity and multiply by timestep
        // consistent acceleration
        self.velocity = CGPointAdd(self.velocity, gravityStep);
    // }
    
    // damp the x speed
    self.velocity = CGPointMake(self.velocity.x * 0.85, self.velocity.y);
    
    
    // clamp the speeds
    self.velocity = CGPointMake(Clamp(self.velocity.x, -kMaxSpeed, kMaxSpeed),
                                Clamp(self.velocity.y, -kMaxSpeed, kMaxSpeed));
    
    // wall sliding speed adjustment
    if (self.characterState == kStateWallSliding) {
        CGFloat fallingSpeed = Clamp(self.velocity.y, kWallSlideSpeed, 0);
        self.velocity = CGPointMake(self.velocity.x, fallingSpeed);
    }
    
    // scale to current timestamp
    CGPoint stepVelocity = CGPointMultiplyScalar(self.velocity, dt);
    
    // adjust the position
    self.desiredPosition = CGPointAdd(self.position, stepVelocity);
}

- (CGRect)collisionBoundingBox {
    // rect start from bottom left, from center shift half left and half down
    CGRect bounding = CGRectMake(self.desiredPosition.x - (kPlayerWidth / 2),
                                 self.desiredPosition.y - (kPlayerHeight / 2),
                                 kPlayerWidth, kPlayerHeight);
    
    // shift the bounding box down by 3
    // return CGRectOffset(bounding, 0, -3);
    return bounding;
}

#pragma mark - Change State

- (void)changeState:(CharacterState)newState {
    // if same, don't else change
    if (newState == self.characterState) return;
    self.characterState = newState;
    
    // cancel all existing animations
    [self removeAllActions];
    SKAction *action = nil;
    
    // check state, set animation/sprite accoridngly
    switch (newState) {
        case kStateStanding: {
            // set texture to the initial texture and update size
            [self setTexture:self.initialTexture];
            [self setSize:self.texture.size];
            break;
        }
        case kStateFalling: {
            // set texture to the falling texture and update size
            [self setTexture:self.fallingTexture];
            [self setSize:self.texture.size];
            break;
        }
        case kStateWalking: {
            // play the walking animation
            action = [SKAction repeatActionForever:self.walkingAnim];
            break;
        }
        case kStateWallSliding: {
            // play wall sliding animation
            action = [SKAction repeatActionForever:self.wallSlideAnim];
            break;
        }
        case kStateJumping: {
            // play jump sound and run the jump animation
            [self runAction:self.jumpSound];
            action = self.jumpUpAnim;
            break;
        }
        case kStateDoubleJumping: {
            // play jump sound and run the jump animation
            [self runAction:self.jumpSound];
            action = self.jumpUpAnim;
            break;
        }
        case kStateDead: {
            // play dying animation, wait 0.5 seconds and then end the game
            action = [SKAction sequence:@[self.dyingAnim,[SKAction waitForDuration:0.5],
                                          [SKAction performSelector:@selector(endGame) onTarget:self]]];
            break;
        }
        default: {
            // set to the initial texture and update size
            [self setTexture:_initialTexture];
            [self setSize:self.texture.size];
            break;
        }
    }
    
    if (action) {
        // run action
        [self runAction:action];
    }
}

#pragma mark - bounce

- (void)bounce {
    // [self runAction:self.playBounceSound];
    self.velocity = CGPointMake(self.velocity.x, kJumpForce / 2);
    self.isActive = NO;
    [self performSelector:@selector(coolDownFinished) withObject:nil afterDelay:0.5];
}

- (void)tookHit:(PSKCharacter *)character {
    self.life = self.life - 100;
    if (self.life < 0) {
        // die
        self.life = 0;
    }
    
    // update player's life
    CGFloat life = self.life;
    CGFloat flo = life/500;
    [self.hud setLife:flo];
    
    if (self.life  <= 0) {
        // dead!
        self.isActive = NO;
        [self changeState:kStateDead];
    } else {
        // make 1/2 invinisible and stop collisions
        self.alpha = 0.5;
        self.isActive = NO;
        
        // apply knockback
        if (self.position.x < character.position.x) {
            self.velocity = CGPointMake(-kKnockback / 2, kKnockback);
        } else {
            self.velocity = CGPointMake(kKnockback / 2, kKnockback);
        }
        
        // begin collisions
        [self performSelector:@selector(coolDownFinished) withObject:nil afterDelay:kCooldown];
    }
}

- (void)killPlayer {
    // set life to 0 and player state to dead
    self.life = 0;
    self.isActive = NO;
    [self.hud setLife:0];
    
    [self changeState:kStateDead];
}

- (void)coolDownFinished {
    // reenable collisions and mark cooldown as ended
    self.alpha = 1.0;
    self.isActive = YES;
}

#pragma mark - Game

- (void)endGame {
    // retrieve scene and then lose the game!
    PSKLevelScene *levelScene = (PSKLevelScene *)self.scene;
    [levelScene loseGame];
}

@end
