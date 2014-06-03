//
//  PSKMyScene.h
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKTAudio.h"

#import "LevelViewController.h"

#import "PSKHUDNode.h"
#import "PSKTurret.h"
#import "PSKBowman.h"

#import "PSKPauseScreen.h"
#import "PSKLoseScreen.h"
#import "PSKWinScreen.h"

#import "Level.h"

@protocol SceneDelegate <NSObject>

// dismiss the scene, to Level Selection/World Selection with a should unlock World
- (void)dismissSceneWithUnlock:(BOOL)unlock;

// present the next level
- (void)presentNextScene;

// represent the level but start from checkpoint
- (void)representSceneFromCheckpoint;

// represent the level
- (void)representThisScene;

// reset all data
- (void)resetData;

@end

// subscribe to all the delegates
@interface PSKLevelScene : SKScene <PSKTurretFire, PSKBowmanFire, PSKHUDNodeDelegate, PauseDelegate, LoseDelegate, UIAlertViewDelegate, WinDelegate>

// public accessable methods
- (void)startTheGame;
- (void)loseGame;
- (void)pauseGame:(BOOL)shouldPlayMusic;

// texture atlas
@property (nonatomic, strong) SKTextureAtlas *atlas;

// game node to hold parallax and everything
@property (nonatomic, strong) SKNode *gameNode;

// hold delegate
@property (nonatomic, assign) id<SceneDelegate> sceneDelegate;

// hold UC retrieval status
@property (nonatomic, assign) BOOL firstGot;
@property (nonatomic, assign) BOOL secondGot;
@property (nonatomic, assign) BOOL thirdGot;

// current level and creation
- (id)initWithSize:(CGSize)size sender:(LevelViewController *)sender atlas:(SKTextureAtlas *)atlas;
- (void)setPlayerPositionToCheckpoint;

@end