//
//  PSKGameManager.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/30/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "Player.h"
#import "World.h"
#import "Level.h"
#import "PSKCharacter.h"

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

@interface PSKGameManager : NSObject

// singleton and context necessary for method calls
+ (PSKGameManager *)sharedManager;
@property (nonatomic, strong) NSManagedObjectContext *context;

// values used to store transitioning between levels and worlds
@property (nonatomic) int worldUID;
@property (nonatomic) int levelUID;

#pragma mark - World Retrieval

// retrieve world with uid
- (World *)retrieveWorldWithUID:(int)uid;

// retrieve all worlds
- (NSArray *)retrieveAllWorlds;

#pragma mark - Level Retrieval

// retrieve leveluid from world's uid
- (Level *)retrieveLevelWithUID:(int)levelUID worldUID:(int)worldUID;

// retrieve all levels for a world
- (NSArray *)retrieveAllLevelsForWorldWithUID:(int)worldUID;

// retrieve leveluid from world's objectID
- (Level *)retrieveLevelWithUID:(int)levelUID worldOID:(NSManagedObjectID *)worldOID;

// retrieve all levels for a world objectID
- (NSArray *)retrieveAllLevelsForWorldWithOID:(NSManagedObjectID *)worldOID;

#pragma mark - PlayerObject

// store the player object directly in memory and the id of the object
@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) NSManagedObjectID *playerObject;

// initialize PLAYER
- (void)initializePlayerID;

// get number of lives, set lives and remove life
- (int)getLives;
- (void)setLifeToPlayer:(int)life;
- (void)removeLifeFromPlayerStats;

// set coins and arrows to player
- (void)setArrowsToPlayerStats:(int)arrows;
- (void)setCoinsToPlayerSTats:(int)coins;

// save all data
- (void)savePlayer;

@end