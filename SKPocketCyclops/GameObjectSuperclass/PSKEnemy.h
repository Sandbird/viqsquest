//
//  PSKEnemy.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/14/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKCharacter.h"

#import "GPlayer.h"
#import "JSTileMap+TileLocations.h"

@interface PSKEnemy : PSKCharacter

// maintain weak reference (else unable to release) to the player and the map
@property (nonatomic, weak) GPlayer *player;
@property (nonatomic, weak) JSTileMap *map;

// remove self
- (void)removeSelf;
- (id)initWithTexture:(SKTexture *)name;

@end
