//
//  PSKLoseScreen.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/9/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol LoseDelegate <NSObject>

// restart with loss
- (void)restartLose;
// return to level listing with loss
- (void)levelListLose;

@end

@class PSKHUDNode;
@interface PSKLoseScreen : SKNode

// delegate reference + creation
- (id)initWithSize:(CGSize)size hud:(PSKHUDNode *)hud;
@property (nonatomic, assign) id<LoseDelegate> delegate;

@end
