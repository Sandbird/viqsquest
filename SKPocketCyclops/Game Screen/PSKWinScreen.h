//
//  PSKWinScreen.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/12/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol WinDelegate <NSObject>

// delegate methods
- (void)nextScene;
- (void)levelList;
- (void)restart;
- (void)levelListWin;

@end

// cannot import so declare @class to say will reference later
@class PSKLevelScene, PSKHUDNode;
@interface PSKWinScreen : SKNode

// store delegate and also create win scene
@property (nonatomic, assign) id<WinDelegate> delegate;
- (id)initWithScreen:(PSKLevelScene *)scene size:(CGSize)size hud:(PSKHUDNode *)hud;

@end
