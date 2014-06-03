//
//  Player.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKCharacter.h"
#import "PSKHUDNode.h"

@interface GPlayer : PSKCharacter

// maintain weak reference to HUD
@property (nonatomic, weak) PSKHUDNode *hud;

@property (nonatomic, assign) BOOL onSlope;

// bounce upon hurt/kill
- (void)bounce;

// update and initiation
- (void)update:(NSTimeInterval)dt;
- (id)initWithImageNamed:(SKTexture *)name;

// kill the player (lethal)
- (void)killPlayer;

@end
