//
//  PSKHUDNode.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreData/CoreData.h>

#import "PSKPauseScreen.h"
#import "Level.h"

@protocol PSKHUDNodeDelegate <NSObject>

// hud delegate
- (void)fireArrow;
- (void)pauseGame:(BOOL)shouldPlayMusic;
- (void)unpauseGame;

@end

@class GPlayer;
@interface PSKHUDNode : SKNode

// declare enums for directions
typedef NS_ENUM(NSInteger, JoystickDirection) {
    kJoyDirectionNone,
    kJoyDirectionLeft,
    kJoyDirectionRight
};

typedef NS_ENUM(NSInteger, JumpButtonState) {
    kJumpButtonOn,
    kJumpButtonOff
};

- (void)unload;

// creation
- (id)initWithSize:(CGSize)size level:(Level *)level atlas:(SKTextureAtlas *)atlas;

// life
- (void)setLife:(CGFloat)life;

// score methods
- (void)addScore:(int)score;
- (void)setScore:(int)score;
- (int)getScore;

// coins
- (void)addCoin;
- (int)getCoin;

// time methods
- (int)currentTime;
- (int)subtractSecond;

// arrow methods
- (void)addArrow;
- (int)arrowAmount;

// set UC gathered
- (void)setFirstGathered;
- (void)setSecondGathered;
- (void)setThirdGathered;

// weak reference to player
@property (nonatomic, weak) GPlayer *player;

// store joydirection and jumpstate
@property (nonatomic, assign) JoystickDirection joyDirection;
@property (nonatomic, assign) JumpButtonState jumpState;

// hud delegate
@property (nonatomic, assign) id<PSKHUDNodeDelegate> delegate;

@end
