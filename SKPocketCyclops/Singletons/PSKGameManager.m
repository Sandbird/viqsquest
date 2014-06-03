//
//  PSKGameManager.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/30/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKGameManager.h"
#import "PSKAppDelegate.h"

#import "PSKSharedTextureCache.h"
#import "SKTAudio.h"

@interface PSKGameManager ()

@property (nonatomic, strong) NSMutableDictionary *entityActions;

@end

@implementation PSKGameManager
@synthesize player;

+ (PSKGameManager *)sharedManager {
    static PSKGameManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if ((self = [super init])) {
        // [self initializePlayerID];
    }
    
    return self;
}

#pragma mark - Fetch Worlds

// retrieve world with a uid
- (World *)retrieveWorldWithUID:(int)uid {
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"uid == %d",uid];
    NSArray *results = [self executeFetchWithName:@"World" predicate:pr];
    
    return results[0];
}

// retrieve all the worlds
- (NSArray *)retrieveAllWorlds {
    NSArray *results = [self executeFetchWithName:@"World" predicate:nil];
    return results;
}
#pragma mark - Fetch Levels

// retrieve leveluid from world's uid
- (Level *)retrieveLevelWithUID:(int)levelUID worldUID:(int)worldUID {
    NSPredicate *pr1 = [NSPredicate predicateWithFormat:@"uid == %d",levelUID];
    NSPredicate *pr2 = [NSPredicate predicateWithFormat:@"world.uid == %d",worldUID];
    NSPredicate *pr = [NSCompoundPredicate andPredicateWithSubpredicates:@[pr1,pr2]];
    
    Level *l = [[self executeFetchWithName:@"Level" predicate:pr] objectAtIndex:0];
    return l;
}

// retrieve all levels for a world
- (NSArray *)retrieveAllLevelsForWorldWithUID:(int)worldUID {
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"world.uid == %d",worldUID];
    return [self executeFetchWithName:@"Level" predicate:pr];
}

// retrieve leveluid from world's objectID
- (Level *)retrieveLevelWithUID:(int)levelUID worldOID:(NSManagedObjectID *)worldOID {
    World *world = (World *)[_context objectRegisteredForID:worldOID];
    
    __block Level *level;
    [[world level] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Level *l = obj;
        if ([[l uid] intValue] == levelUID) {
            level = obj;
            *stop = YES;
        }
    }];
    
    return level;
}

// retrieve all levels for a world objectID
- (NSArray *)retrieveAllLevelsForWorldWithOID:(NSManagedObjectID *)worldOID {
    World *world = (World *)[_context objectRegisteredForID:worldOID];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    return [[[world level] allObjects] sortedArrayUsingDescriptors:@[sort]];
}

#pragma mark - Player

// return player lives
- (int)getLives {
    return [player.livesLeft intValue];
}

// initialize PLAYERID
- (void)initializePlayerID {
    Player *p = [[self executeFetchWithName:@"Player" predicate:nil] objectAtIndex:0];
    player = p;
    _playerObject = [p objectID];
}

// set number of lives to the player
- (void)setLifeToPlayer:(int)life {
    Player *p = (Player *)[_context existingObjectWithID:_playerObject error:nil];
    [p setLivesLeft:[NSNumber numberWithInt:life]];
    
    player = p;
}

// remove a life from player
- (void)removeLifeFromPlayerStats {
    Player *p = (Player *)[_context existingObjectWithID:_playerObject error:nil];
    [p setLivesLeft:[NSNumber numberWithInt:p.livesLeft.intValue - 1]];
    
    player = p;
}

// set arrows to player
- (void)setArrowsToPlayerStats:(int)arrows {
    Player *p = (Player *)[_context existingObjectWithID:_playerObject error:nil];
    [p setArrowsLeft:[NSNumber numberWithInt:arrows]];
    
    player = p;
}

// set coins to player
- (void)setCoinsToPlayerSTats:(int)coins {
    Player *p = (Player *)[_context existingObjectWithID:_playerObject error:nil];
    [p setCoins:[NSNumber numberWithInt:coins]];
    
    player = p;
}

// save all the data
- (void)savePlayer {
    NSError *error;
    [_context save:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        exit(1);
    }
}

#pragma mark - Execute Helper Method

// fetch with name and predicate
- (NSArray *)executeFetchWithName:(NSString *)name predicate:(NSPredicate *)predicate {
    if (_context == nil) {
        PSKAppDelegate *ap = (PSKAppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = [ap managedObjectContext];
    }
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:name];
    [fetch setPredicate:predicate];
    
    if (![name isEqualToString:@"Player"]) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
        [fetch setSortDescriptors:@[sort]];
    }
    
    [fetch setReturnsObjectsAsFaults:NO];
    
    NSError *error;
    NSArray *results = [_context executeFetchRequest:fetch error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return results;
}

@end
