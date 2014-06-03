//
//  PSKPauseScreen.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/8/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol PauseDelegate <NSObject>

// pause delegate
- (void)restart;
- (void)levelList;
- (void)unpauseGame;

@end

@class PSKHUDNode;
@interface PSKPauseScreen : SKNode

// reference + create with size
- (id)initWithSize:(CGSize)size hud:(PSKHUDNode *)hude;
@property (nonatomic, assign) id<PauseDelegate> delegate;

@end
