//
//  PSKMyScene.m
//  SKPocketCyclops
//
//  Created by William Zhang on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKLevelScene.h"
#import "PSKAppDelegate.h"

#import "PSKSharedTextureCache.h"
#import "PSKGameManager.h"

#import "JLGParallaxNode.h"
#import "JSTileMap+TileLocations.h"

#import "GPlayer.h"
#import "PSKGB.h"
#import "PSKKnight.h"
#import "PSKHound.h"

#import "PSKArrow.h"
#import "PSKArrowCollectable.h"
#import "PSKCoin.h"
#import "PSKUC.h"
#import "PSKPowerLiteral.h"
#import "SlopeObject.h"

#import "PSKCheckpoint.h"
#import "PSKPlatform.h"
#import "PSKLethalHazard.h"
#import "PSKNonLethalHazard.h"

@interface PSKLevelScene () {
    // store the last attached slope rectangle
    CGRect lastHitSlope;
}

// store everything map related
@property (nonatomic, weak) JSTileMap *map;
@property (nonatomic, weak) TMXLayer *walls;
@property (nonatomic, weak) TMXLayer *meta_layer;
@property (nonatomic, weak) TMXLayer *enemy_collide;

@property (nonatomic) NSMutableArray *slopes;
@property (nonatomic, weak) TMXLayer *slope;

// store checkpoint + has reached checkpoint
@property (nonatomic, assign) BOOL hasReachedCheckpoint;
@property (nonatomic) PSKCheckpoint *checkpoint;

// store exit point and whether game is running
@property (nonatomic, assign) CGPoint exitPoint;
@property (nonatomic, assign) BOOL gameRunning;

// store hud
@property (nonatomic) PSKHUDNode *hud;

// store references to pause/lose/win
@property (nonatomic) PSKPauseScreen *pause;
@property (nonatomic) PSKLoseScreen *lose;
@property (nonatomic) PSKWinScreen *win;

// reference player and previous Delta
@property (nonatomic) GPlayer *player;
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;

// store platform array
@property (nonatomic) NSMutableArray *platforms;

// store hazards + enemies + arrows
@property (nonatomic) NSMutableArray *hazards;
@property (nonatomic) NSMutableArray *enemies;
@property (nonatomic) NSMutableArray *arrows;

// store coins + arrowables + UCs + powerups
@property (nonatomic) NSMutableArray *coins;
@property (nonatomic) NSMutableArray *arrowables;
@property (nonatomic) NSMutableArray *uniqueCollectables;
@property (nonatomic) NSMutableArray *powerups;

// countdown action
@property (nonatomic) SKAction *countdownTimerAction;

// texture atlas and sound effects dictionary and actual sound loader
@property (nonatomic) SKTextureAtlas *sceneAtlas;
@property (nonatomic) NSMutableDictionary *soundLoader;
@property (nonatomic) NSMutableDictionary *soundEffects;

@end

@implementation PSKLevelScene

#pragma mark - initialization and setup and parallax

- (id)initWithSize:(CGSize)size sender:(LevelViewController *)sender atlas:(SKTextureAtlas *)atlas {
    if ((self = [super initWithSize:size])) {
        // set level and world ID
        int luid, wuid;
        luid = [[PSKGameManager sharedManager] levelUID];
        wuid = [[PSKGameManager sharedManager] worldUID];
        
        // store atlas
        self.atlas = atlas;
        
        // retrieve resource of levels
        NSString *path = [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"];
        
        // convert path to dictionary
        NSDictionary *allLevelsDict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        // construct the level string
        NSString *levelString = [NSString stringWithFormat:@"level%d%d", wuid,luid];
        
        // retrieve important parts
        NSDictionary *levelDict = allLevelsDict[levelString];
        
        // load music and play the background music
        NSString *musicFilename = levelDict[@"music"];
        [[SKTAudio sharedInstance] playBackgroundMusic:musicFilename];
        
        // create node and add to screen
        self.gameNode = [SKNode node];
        
        // load the parallax background
        [self loadParallaxBackground:levelDict];
        
        // load the tiledmap using level name
        NSString *levelName = [levelDict objectForKey:@"level"];
        self.map = [JSTileMap mapNamed:levelName];
        
        // retrieve all the level's layers
        self.walls = [self.map layerNamed:@"walls"];
        self.meta_layer = [self.map layerNamed:@"meta_layer"];
        self.enemy_collide = [self.map layerNamed:@"enemy_collide"];
        self.slope = [self.map layerNamed:@"slope"];
        
        // set hidden to enemy_collide and meta_layer
        [self.enemy_collide setHidden:YES];
        [self.meta_layer setHidden:YES];
        
        // create player with z position and add to screen
        // get object layer, player dictionary and set player's position
        TMXObjectGroup *objects = [self.map groupNamed:@"objects"];
        NSDictionary *playerObj = [objects objectNamed:@"player"];
        
        SKTexture *texture = [atlas textureNamed:@"Player1.png"];
        self.player = [[GPlayer alloc] initWithImageNamed:texture];
        self.player.zPosition = 900;
        self.player.position = CGPointMake([playerObj[@"x"] floatValue], [playerObj[@"y"] floatValue]);
        
        // load all the sound effects
        self.soundLoader = [NSMutableDictionary dictionary];
        self.soundEffects = [NSMutableDictionary dictionary];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadSounds];
            [self attachDispatchSound];
        });
        
        // load the checkpoint
        [self loadCheckpoint];
        
        // initialize powerups and sloeps array
        self.powerups = [NSMutableArray array];
        self.slopes = [NSMutableArray array];
        
        // load hazards + coins + arrow collectables
        self.hazards = [NSMutableArray array];
        self.coins = [NSMutableArray array];
        self.arrowables = [NSMutableArray array];
        [self loadCandA];
        
        // load all the unique collectables
        self.uniqueCollectables = [NSMutableArray array];
        [self loadUCs];
        
        self.platforms = [NSMutableArray array];
        [self loadPlatforms];
        
        // load enemies
        [self loadEnemies];
        self.arrows = [NSMutableArray array];
        
        // load the exit and set the rectangle
        NSDictionary *exit = [objects objectNamed:@"exit"];
        self.exitPoint = CGPointMake([exit[@"x"] floatValue], [exit[@"y"] floatValue]);
        
        // get the current level and create the HUD
        Level *level = [sender objectAtWorld:luid];
        self.hud = [[PSKHUDNode alloc] initWithSize:size level:level atlas:atlas];
        self.hud.delegate = self;
        self.hud.zPosition = 1000;
        
        self.player.hud = self.hud;
        self.hud.player = self.player;
        self.gameRunning = NO;
        
        // add all the necessary children
        [self addChild:self.gameNode];
        [self.gameNode addChild:self.map];
        [self.map addChild:self.player];
        [self addChild:self.hud];
        
        [self setViewpointCenter:self.player.position];
    }
    
    return self;
}

- (void)setPlayerPositionToCheckpoint {
    // get teh checkpoint, mark checkpoint as YES
    // set the correct texture and the update the player's position
    self.player.position = CGPointMake(self.checkpoint.position.x,
                                       self.checkpoint.position.y + 5 + self.player.collisionBoundingBox.size.height/2);
    self.hasReachedCheckpoint = YES;
    [self.checkpoint setTexture:[self.atlas textureNamed:@"FlagReached.png"]];
}

- (void)startTheGame {
    // set game running to YES
    self.gameRunning = YES;
    
    // add a countdown time action
    SKAction *timeAction = [SKAction waitForDuration:1.0];
    SKAction *executeAction = [SKAction performSelector:@selector(timerCountdownToZero) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[timeAction, executeAction]];
    self.countdownTimerAction = [SKAction repeatActionForever:sequence];
    [self runAction:self.countdownTimerAction withKey:@"Countdown"];
}

- (void)loadParallaxBackground:(NSDictionary *)levelDict {
    // create parallel node and also load the background images
    JLGParallaxNode *parallaxNode = [JLGParallaxNode node];
    
    /*
     OpenGL and Sprite Kit have maximum texture size.
     Exceed and require to do tiling!
    */
    
    // load array with arrays containing images
    NSArray *backgroundArray = levelDict[@"background"];
    
    @autoreleasepool {
        for (NSArray *layerArray in backgroundArray) {
            // shift things at different speed based off index
            CGFloat indexOfLayer = [backgroundArray indexOfObject:layerArray] + 1.0;
            CGFloat ratio = (4.0 - indexOfLayer) / 4.0;
            
            if (indexOfLayer == 4.0) {
                ratio = 0.0;
            }
            
            for (NSString *chunkFilename in layerArray) {
                // create sprite node utilizing the image named
                NSString *file = [[NSBundle mainBundle] pathForResource:chunkFilename ofType:@"png"];
                NSData *data = [NSData dataWithContentsOfFile:file];
                UIImage *image = [UIImage imageWithData:data];
                
                SKSpriteNode *backgroundSprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
                // set anchor point to bottom left
                backgroundSprite.anchorPoint = CGPointMake(0.0, 0.0);
                
                // get index to position it in the correct position
                NSInteger indexOfChunk = [layerArray indexOfObject:chunkFilename];
                
                // add image at the appropriate z, with the appropriate speed and positioning offset
                [parallaxNode addChild:backgroundSprite z:-indexOfLayer
                         parallaxRatio:CGPointMake(ratio, 0.6)
                        positionOffset:CGPointMake(indexOfChunk * 1024, 30)];
            }
        }
    }
    
    // add the paralax node, give it a name set the z to really low
    // to make it below everything else
    [self.gameNode addChild:parallaxNode];
    parallaxNode.name = @"parallax";
    parallaxNode.zPosition = -1000;
}

- (void)loadUCs {
    // get all the unique collectables from objects
    TMXObjectGroup *group = [self.map groupNamed:@"objects"];
    for (NSDictionary *dict in [group objects]) {
        // create the PSKUC object, set the position + anchor point
        if ([dict valueForKey:@"UC"]) {
            PSKUC *uc = [[PSKUC alloc] initWithTexture:[self.atlas textureNamed:@"swordGold.png"]];
            uc.zPosition = 250;
            uc.anchorPoint = CGPointMake(0, 0);
            
            // set the placement and the order
            if ([dict valueForKey:@"1"]) {
                [uc setPlacement:1];
            } else if ([dict valueForKey:@"2"]) {
                [uc setPlacement:2];
            } else if ([dict valueForKey:@"3"]) {
                [uc setPlacement:3];
            }
            
            // set the uc to the correct position
            CGPoint tileCoord = [self.map tileCoordForPosition:CGPointMake([dict[@"x"] intValue] + 1, [dict[@"y"] intValue] + 1)];
            uc.position = [self.map tileRectFromTileCoords:tileCoord].origin;
            
            [self.uniqueCollectables addObject:uc];
            [self.map addChild:uc];
        }
    }
}

- (void)loadSounds {
    // load each sound from file and add it to the dictionary
    SKAction *arrowc = [SKAction playSoundFileNamed:@"arrow_collect.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"arrow_collect"];
    
    arrowc = [SKAction playSoundFileNamed:@"coin_collect.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"coin_collect"];
    
    arrowc = [SKAction playSoundFileNamed:@"game_over.mp3" waitForCompletion:YES];
    [self.soundLoader setObject:arrowc forKey:@"game_over"];
    
    arrowc = [SKAction playSoundFileNamed:@"hurt.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"hurt"];
    
    arrowc = [SKAction playSoundFileNamed:@"jump_kill.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"jump_kill"];
    
    arrowc = [SKAction playSoundFileNamed:@"level_clear.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"level_clear"];
    
    arrowc = [SKAction playSoundFileNamed:@"life_death.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"life_death"];
    
    arrowc = [SKAction playSoundFileNamed:@"pause.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"pause"];
    
    arrowc = [SKAction playSoundFileNamed:@"powerup_appear.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"powerup_appear"];
    
    arrowc = [SKAction playSoundFileNamed:@"powerup_collect.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"powerup_collect"];
    
    arrowc = [SKAction playSoundFileNamed:@"uc_collect.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"uc_collect"];
    
    arrowc = [SKAction playSoundFileNamed:@"arrow_fire.mp3" waitForCompletion:NO];
    [self.soundLoader setObject:arrowc forKey:@"arrow_fire"];
}

- (void)attachDispatchSound {
    // run through all the keys,
    // create a block that executes if not muted, retrieve action given and run the sound
    NSArray *keys = [self.soundLoader allKeys];
    for (NSString *key in keys) {
        SKAction *arrowc = [SKAction runBlock:^{
            if (![[SKTAudio sharedInstance] isMuted]) {
                SKAction *action = self.soundLoader[key];
                [self runAction:action];
            }
        }];
        [self.soundEffects setObject:arrowc forKey:key];
    }
}

- (void)loadCheckpoint {
    // get checkpoint coord
    TMXObjectGroup *group = [self.map groupNamed:@"objects"];
    NSDictionary *checkpoint = [group objectNamed:@"Checkpoint"];
    
    // create checkpoint instance
    self.checkpoint = [[PSKCheckpoint alloc] initWithTexture:[self.atlas textureNamed:@"Flag.png"]];
    self.checkpoint.zPosition = 250;
    self.checkpoint.anchorPoint = CGPointMake(0, 0);
    
    // place checkpoint location
    CGPoint tileCoord = [self.map tileCoordForPosition:CGPointMake([checkpoint[@"x"] intValue] + 1, [checkpoint[@"y"] intValue] + 1)];
    self.checkpoint.position = [self.map tileRectFromTileCoords:tileCoord].origin;
    [self.map addChild:self.checkpoint];
}

- (void)loadPlatforms {
    TMXObjectGroup *platformGroup = [self.map groupNamed:@"platforms"];
    for (NSDictionary *platformDict in platformGroup.objects) {
        // get platform
        NSString *type = platformDict[@"type"];
        CGFloat speed = [platformDict[@"speed"] floatValue];
        CGFloat distanceToMove = [platformDict[@"distanceToMove"] floatValue];
        
        // create platform using texture, type, speed and distanceToMove
        PSKPlatform *platform = [[PSKPlatform alloc] initWithImageNamed:[self.atlas textureNamed:@"platformIce.png"] forPlatformType:type withSpeed:speed andDistance:distanceToMove];
        
        // add the platform
        [self.platforms addObject:platform];
        platform.position = CGPointMake([platformDict[@"x"] floatValue], [platformDict[@"y"] floatValue]);
        platform.zPosition = 850;
        [self.map addChild:platform];
    }
}

- (void)loadCandA {
    // scan through all the tiles in the level. create corresponding tile
    // remove the tile from removetileatcoord
    for (int i = 0; i < self.map.mapSize.width; i++) {
        for (int j = 0; j < self.map.mapSize.height; j++) {
            CGPoint tile = CGPointMake(i, j);
            if ([self.meta_layer tileGIDAtTileCoord:tile]) {
                NSDictionary *properties = [self.map propertiesForGid:[self.meta_layer tileGIDAtTileCoord:tile]];
                if ([properties[@"Coin"] intValue] == 1) {
                    // if a coin, create the pskcoin, set the positioning and add it to coins
                    PSKCoin *coin = [[PSKCoin alloc] initWithTexture:[self.atlas textureNamed:@"Coin.png"]];
                    coin.zPosition = 250;
                    coin.anchorPoint = CGPointMake(0, 0);
                    coin.position = [self.map tileRectFromTileCoords:tile].origin;
                    
                    [self.coins addObject:coin];
                    [self.map addChild:coin];
                    
                    [self.meta_layer removeTileAtCoord:tile];
                } else if ([properties[@"Arrow"] intValue] == 1) {
                    // if an arrowable, create the pskarrowcollectable, set the positioning and add it to arrows
                    PSKArrowCollectable *ac = [[PSKArrowCollectable alloc] initWithTexture:[self.atlas textureNamed:@"Arrowcollect.png"]];
                    ac.zPosition = 250;
                    ac.anchorPoint = CGPointMake(0, 0);
                    ac.position = [self.map tileRectFromTileCoords:tile].origin;
                    
                    [self.arrowables addObject:ac];
                    [self.map addChild:ac];
                    
                    [self.meta_layer removeTileAtCoord:tile];
                } else if ([properties[@"HazardL"] intValue] == 1) {
                    // if there is a lethal hazard, create the lethal hazard from the rectangle
                    CGRect tileRect = [self.map tileRectFromTileCoords:tile];
                    PSKLethalHazard *l = [[PSKLethalHazard alloc] initWithRect:tileRect];
                    [self.hazards addObject:l];
                    
                    [self.meta_layer removeTileAtCoord:tile];
                } else if ([properties[@"HazardNL"] intValue] == 1) {
                    // if there is a nonlethal hazard, create the nl hazard from the rectangle
                    CGRect tileRect = [self.map tileRectFromTileCoords:tile];
                    PSKNonLethalHazard *nl = [[PSKNonLethalHazard alloc] initWithRect:tileRect];
                    [self.hazards addObject:nl];
                    
                    [self.meta_layer removeTileAtCoord:tile];
                } else if ([properties[@"Fire"] intValue] == 1) {
                    // if there is a fire "sprite" create the non lethal hazard at location
                    CGRect tileRect = [self.map tileRectFromTileCoords:tile];
                    PSKNonLethalHazard *nl = [[PSKNonLethalHazard alloc] initWithRect:tileRect];
                    [self.hazards addObject:nl];
                    
                    // create the skemitter node and add it to the game
                    NSString *emitter = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
                    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitter];
                    [emitterNode setZPosition:1000];
                    
                    CGRect tie = [self.map tileRectFromTileCoords:tile];
                    [emitterNode setPosition:CGPointMake(tie.origin.x + 8, tie.origin.y + 8)];
                    [self.map addChild:emitterNode];
                    
                    [self.meta_layer removeTileAtCoord:tile];
                }
            } else if ([self.slope tileGIDAtTileCoord:tile] != 0) {
                // create a slope object depending on the rectangle and the slope direction
                CGRect rect = [self.map tileRectFromTileCoords:tile];
                NSDictionary *properties = [self.map propertiesForGid:[self.slope tileGIDAtTileCoord:tile]];
                BOOL isUp = NO;
                if ([properties[@"Up"] intValue] == 1) {
                    isUp = YES;
                }
                
                SlopeObject *slope = [[SlopeObject alloc] initWithRect:rect up:isUp];
                [self.slopes addObject:slope];
            }
        }
    }
}

- (void)loadEnemies {
    // initialize array and the objects group
    self.enemies = [NSMutableArray array];
    TMXObjectGroup *enemiesGroup = [self.map groupNamed:@"enemies"];
    
    for (NSDictionary *enemyDict in enemiesGroup.objects) {
        NSString *enemyType = enemyDict[@"type"];
        
        // set the first frame image to the enemy
        NSString *firstFrameName = [NSString stringWithFormat:@"%@1.png",enemyType];
        
        // create enemy and position the enemy
        id enemy = [[NSClassFromString(enemyType) alloc] initWithTexture:[self.atlas textureNamed:firstFrameName]];

        // if enemy is a turret
        if ([enemyType isEqualToString:@"PSKTurret"]) {
            // set position
            [(PSKTurret *)enemy setPosition:CGPointMake([enemyDict[@"x"] intValue] + 32, [enemyDict[@"y"] intValue] + 25)];
            if ([enemyDict[@"CeilingMounted"] isEqualToString:@"NO"]) {
                // check if it is ceiling mounted and set values
                PSKTurret *t = (PSKTurret *)enemy;
                [t setDelegate:self];
                [t setIsGroundMounted:YES];
            } else {
                // if ceiling mounted, set life to 100 and adjust rotation
                // set the turret's rotation to 0 or 1
                PSKTurret *t = (PSKTurret *)enemy;
                [t setDelegate:self];
                [t setIsGroundMounted:NO];
                [t setLife:100];
                
                if ([enemyDict[@"Rotation"] isEqualToString:@"M_PI_2"]) {
                    t.zRotation = M_PI_2;
                    [t setRotation:1];
                } else {
                    t.zRotation = 0;
                    [t setRotation:0];
                }
            }
        } else if ([enemyType isEqualToString:@"PSKBowman"]) {
            // if bowman, set the anchor point to (0,0) and set the position and delegate
            [enemy setAnchorPoint:CGPointMake(0, 0)];
            
            [(PSKBowman *)enemy setPosition:CGPointMake([enemyDict[@"x"] intValue], [enemyDict[@"y"] intValue])];
            [(PSKBowman *)enemy setDelegate:self];
        } else // position it
            [(PSKEnemy *)enemy setPosition:CGPointMake([enemyDict[@"x"] intValue], [enemyDict[@"y"] intValue])];
        
        // set the player object of the enemy to the player and the map
        [(PSKEnemy *)enemy setPlayer:self.player];
        [enemy setMap:self.map];
        
        // add enemy to map and the enemies array
        [self.map addChild:enemy];
        [enemy setZPosition:900];
        [self.enemies addObject:enemy];
    }
}

- (void)setViewpointCenter:(CGPoint)position {
    // keep adjusting the viewpoint, keeping the player in the center of the screen and not going over the edges
    NSInteger x = MAX(position.x, self.size.width / 2);
    NSInteger y = MAX(position.y, self.size.height / 2);
    x = MIN(x, (self.map.mapSize.width * self.map.tileSize.width) - self.size.width / 2);
    y = MIN(y, (self.map.mapSize.height * self.map.tileSize.height) - self.size.height / 2);
    CGPoint actualPosition = CGPointMake(x, y);
    CGPoint centerOfView = CGPointMake(self.size.width/2, self.size.height/2);
    CGPoint viewPoint = CGPointSubtract(centerOfView, actualPosition);
    
    self.gameNode.position = viewPoint;
}

#pragma mark - Time

- (void)timerCountdownToZero {
    // if game is running, subtract
    // if out of time, remove the action and kill the player
    if (self.gameRunning) {
        if ([self.hud subtractSecond] <= 0) {
            [self removeActionForKey:@"Countdown"];
            [self.player killPlayer];
        }
    }
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime {
    if (!self.gameRunning) return;
    
    // length of time passed between previous and now
    NSTimeInterval delta = currentTime - self.previousUpdateTime;
    self.previousUpdateTime = currentTime;
    
    // if delta is too big = huge movement, cap the delta
    if (delta > 0.03) {
        delta = 0.01;
    }
    
    // update player position and check for collision with walls
    [self.player update:delta];
    [self enemyCheckForAndResolveTwoTileCollisions:self.player];
    
    // update all the platform position and velocity
    // check if player collided with any platform
    for (PSKPlatform *platform in self.platforms) {
        [platform update:delta];
        [self checkForPlatformCollision:platform];
    }
    
    // if player reached checkpoint, change checkpoint image and then set hasReachedCheckpoint to YES
    if (CGRectIntersectsRect(self.player.collisionBoundingBox, self.checkpoint.frame) && !self.hasReachedCheckpoint) {
        self.hasReachedCheckpoint = YES;
        [self.checkpoint setTexture:[self.atlas textureNamed:@"FlagReached.png"]];
    }
    
    // loop through all enemies
    // create a nsmutableset to prevent double entries and to delete objects. cannot remove objects
    // from an array during fast enumeration
    NSMutableSet *enemiesThatNeedDeleting = [NSMutableSet set];
    for (PSKEnemy *enemy in self.enemies) {
        // update the enemy position
        [enemy update:delta];
        
        // if enemy is not a bowman/turret
        if (![enemy isKindOfClass:[PSKTurret class]] && ![enemy isKindOfClass:[PSKBowman class]]) {
            // if enemy is PSKGB, check for 1 tile-size collision
            if ([enemy isKindOfClass:[PSKGB class]]) {
                [self checkForAndResolveOneTileCollisions:enemy];
            }
            
            // if knight and not cowering, check for 2 tile-size collision
            if ([enemy isKindOfClass:[PSKKnight class]]) {
                PSKKnight *knight = (PSKKnight *)enemy;
                if (![knight isCowering]) {
                    [self enemyCheckForAndResolveTwoTileCollisions:knight];
                }
            }
            
            // if hound, check for 2 tile-wide-size collision
            if ([enemy isKindOfClass:[PSKHound class]]) {
                [self enemyCheckForAndResolveTwoTileCollisions:enemy];
            }
        }
        
        // if enemy is active, check for enemy and player collision
        if (enemy.isActive) {
            [self checkForEnemyCollisions:enemy];
        }
        
        // if enemy is dead, add object to the set
        if (!enemy.isActive  && enemy.characterState == kStateDead) {
            if (enemiesThatNeedDeleting == nil) {
                enemiesThatNeedDeleting = [NSMutableSet set];
            }
            
            [enemiesThatNeedDeleting addObject:enemy];
        }
    }
    
    // loop through all the arrows
    NSMutableSet *arrowsThatNeedDeleting = [NSMutableSet set];
    for (PSKArrow *arrow in self.arrows) {
        // update the arrow's position
        [arrow update:delta];
        
        // if arrow collides with the walls, add arrow to the arrow set
        if ([PSKArrow checkForAndResolveCollisions:self.walls arrow:arrow map:self.map]) {
            [arrowsThatNeedDeleting addObject:arrow];
        }
        
        // if the arrow collides with any enemy, and the arrow if fired by player
        // damage the enemy, play sound, add score and add arrow to the set
        for (PSKEnemy *enemy in self.enemies) {
            if (CGRectIntersectsRect(enemy.collisionBoundingBox, arrow.collisionBoundingBox) && !arrow.isFiredByTurret) {
                [enemy tookHit:nil];
                [arrowsThatNeedDeleting addObject:arrow];
                
                [self runAction:self.soundEffects[@"jump_kill"]];
                [self.hud addScore:200];
            }
        }
        
        // if arrow hits player and fired by turret, damage player, add arrow to
        // the set and play sound effect
        if (CGRectIntersectsRect(self.player.collisionBoundingBox, arrow.collisionBoundingBox) && arrow.isFiredByTurret
            && self.player.isActive) {
            [arrowsThatNeedDeleting addObject:arrow];
            [self.player tookHit:nil];
            
            [self runAction:self.soundEffects[@"hurt"]];
        }
    }
    
    // enumerate through all toDelete enemies. remove from the enemy array
    // and remove the enemy sprite
    for (PSKEnemy *enemy in enemiesThatNeedDeleting) {
        [self.enemies removeObject:enemy];
        [enemy removeFromParent];
    }
    
    // enumerate through all toDelete arrows. remove from the arrow array
    // and remove the arrow sprite
    for (PSKArrow *arrow in arrowsThatNeedDeleting) {
        [self.arrows removeObject:arrow];
        [arrow removeFromParent];
    }
    
    // check if collide with any objects/hazards
    [self checkForHazardCollision];
    [self checkForCoinCollisions];
    [self checkCollisionWithUC];
    [self checkForArrowCollectableCollision];
    [self powerupCollisions];
    
    // see if level accomplished
    [self checkForExit];
    
    // update viewpoint
    [self setViewpointCenter:self.player.position];
}

#pragma mark - Arrow

- (void)fireArrow {
    CGPoint velocity;
    float rotation;
    // set velocity dpending on direction
    // use flipX to judge, flipX = NO, is going right
    if (!self.player.flipX) {
        velocity = CGPointMake(450, 0);
        rotation = M_PI;
    } else {
        velocity = CGPointMake(-450, 0);
        rotation = 0;
    }
    
    // create arrow and add it to array and map
    velocity = CGPointMultiplyScalar(velocity, 0.01);
    PSKArrow *arrow = [self createArrowAccordingly:velocity rotation:rotation position:self.player.position isPlayer:YES];
    arrow.zPosition = 450;
    [self.map addChild:arrow];
    [self.arrows addObject:arrow];
}

- (void)firedTurret:(PSKEnemy *)turret {
    PSKTurret *tur = (PSKTurret *)turret;
    
    // if the turret is a rotating turet
    if (tur.isGroundMounted) {
        // calculate the difference between turret and player
        CGPoint subtract = CGPointSubtract(self.player.position, tur.position);
        CGPoint speedScalar;
        
        // force x speed to 300 and calculate correspnoding y speed depending on rotation
        // of the turret
        CGFloat f = 300 * tanf(tur.arm.zRotation);
        if (subtract.x > 0) {
            speedScalar = CGPointMake(300, f);
        } else {
            // invert the y, due to the angle or rotation
            speedScalar = CGPointMake(-300, -f);
        }
        
        // scale down the arrow to a speed, assuming 60 frames per second
        speedScalar = CGPointMultiplyScalar(speedScalar, 0.01);
        
        // create the arrow and add it to array and map
        PSKArrow *arrow = [self createArrowAccordingly:speedScalar rotation:tur.arm.zRotation position:tur.position isPlayer:NO];
        [self.map addChild:arrow];
        [self.arrows addObject:arrow];
    } else {
        // read the rotation value on the turret and generate velocity
        CGPoint speedScalar = CGPointZero;
        if (tur.rotation == 0) {
            speedScalar = CGPointMake(-300, 0);
        } else if (tur.rotation == 1) {
            speedScalar = CGPointMake(0, -300);
        }
        
        // scale down velocity
        speedScalar = CGPointMultiplyScalar(speedScalar, 0.01);
        
        // create arrow, add it to array amd map
        PSKArrow *arrow = [self createArrowAccordingly:speedScalar rotation:tur.zRotation position:tur.position isPlayer:NO];
        [self.map addChild:arrow];
        [self.arrows addObject:arrow];
    }
}

- (void)bowmanFired:(PSKEnemy *)turret {
    // create a hypothetical position, position where the crossbow is held
    // by the bowman sprite
    PSKBowman *tur = (PSKBowman *)turret;
    CGPoint pos = CGPointMake(tur.position.x + 15, tur.position.y + 32);
    CGPoint subtract = CGPointSubtract(self.player.position, pos);
    CGPoint speedScalar;
    
    // calculate x and y speed just like in the turret
    CGFloat f = 300 * tanf(tur.arm.zRotation);
    if (subtract.x > 0) {
        speedScalar = CGPointMake(300, f);
    } else {
        speedScalar = CGPointMake(-300, -f);
    }
    
    // scale it down to 60fps
    speedScalar = CGPointMultiplyScalar(speedScalar, 0.01);
    
    // create arrow. add it to map and array
    PSKArrow *arrow = [self createArrowAccordingly:speedScalar rotation:tur.arm.zRotation position:pos isPlayer:NO];
    [self.map addChild:arrow];
    [self.arrows addObject:arrow];
}

- (PSKArrow *)createArrowAccordingly:(CGPoint)velocity rotation:(float)rotation position:(CGPoint)position isPlayer:(BOOL)pFire {
    // create the arrow with the texture
    PSKArrow *arrow = [[PSKArrow alloc] initWithTexture:[self.atlas textureNamed:@"ArrowheadLeft.png"]];
    
    // set the anchor point
    arrow.anchorPoint = CGPointMake(1, 0.5);
    
    // set velocity + rotation + position + who fired it
    arrow.velocity = velocity;
    arrow.position = position;
    arrow.zRotation = rotation;
    arrow.isFiredByTurret = !pFire;
    
    // set the zposition
    arrow.zPosition = 450;
    
    // play sound file
    [self runAction:self.soundEffects[@"arrow_fire"]];
    return arrow;
}

#pragma mark - Coin Collision

- (void)checkForCoinCollisions {
    // check if coin collides and remove
    [self checkCollidablesAndRemoveThem:self.coins];
}

- (void)checkForArrowCollectableCollision {
    // check if arrowables collide and remove
    [self checkCollidablesAndRemoveThem:self.arrowables];
}

#pragma mark - Powerup Collision

- (void)powerupCollisions {
    // check if powerup collide and remove
    [self checkCollidablesAndRemoveThem:self.powerups];
}

#pragma mark - UC Collision

- (void)checkCollisionWithUC {
    // check if UC collide and remove
    [self checkCollidablesAndRemoveThem:self.uniqueCollectables];
}

#pragma mark - Item Collision Detection

- (void)checkCollidablesAndRemoveThem:(NSMutableArray *)collidables {
    // create a set to store objects to delete
    NSMutableSet *toDelete = [NSMutableSet set];
    for (PSKGameObject *obj in collidables) {
        // if the player is collising with a game object
        if (CGRectIntersectsRect(self.player.collisionBoundingBox, obj.frame)) {
            // add the object to the set of toDelete
            [toDelete addObject:obj];
            
            if ([obj isKindOfClass:[PSKCoin class]]) {
                // if collide with coin
                // call the HUD's addCoin + addScore and play audio effects
                [self.hud addCoin];
                [self.hud addScore:200];
                
                [self runAction:self.soundEffects[@"coin_collect"]];
            } else if ([obj isKindOfClass:[PSKArrowCollectable class]]) {
                // add an arrow
                [self.hud addArrow];
                [self.hud addScore:200];
                
                [self runAction:self.soundEffects[@"arrow_collect"]];
            } else if ([obj isKindOfClass:[PSKUC class]]) {
                // set gathered one, depending on the placement of the UC
                PSKUC *uc = (PSKUC *)obj;
                switch (uc.placement) {
                    case 1:
                        self.firstGot = YES;
                        [self.hud setFirstGathered];
                        break;
                    case 2:
                        self.secondGot = YES;
                        [self.hud setSecondGathered];
                        break;
                    case 3:
                        self.thirdGot = YES;
                        [self.hud setThirdGathered];
                        break;
                    default:
                        break;
                }
                
                [self.hud addScore:200];
                [self runAction:self.soundEffects[@"uc_collect"]];
            } else if ([obj isKindOfClass:[PSKPowerLiteral class]]) {
                PSKPowerLiteral *power = (PSKPowerLiteral *)obj;
                if (CGRectIntersectsRect(power.frame, self.player.collisionBoundingBox)) {
                    // depending on the powerup, apply the correct action
                    if (power.powerup == FullHealth) {
                        // if collected a full health powerup, set life to 500
                        // set HUD set life to 1
                        self.player.life = 500;
                        [self.hud setLife:1];
                    } else if (power.powerup == Add1Health) {
                        // if player life, is less than 500, add 100 to life
                        // clamp life to 500 and update accordingly
                        CGFloat playerLife = self.player.life;
                        if (playerLife < 500) {
                            playerLife = playerLife + 100;
                            if (playerLife > 500) {
                                playerLife = 500;
                            }
                            
                            self.player.life = playerLife;
                        }
                        CGFloat ratio = playerLife / 500;
                        [self.hud setLife:ratio];
                    } else if (power.powerup == Plus10Arrows) {
                        // add 10 arrows to the player
                        for (int i = 0; i < 10; i++) {
                            [self.hud addArrow];
                        }
                    } else if (power.powerup == Plus20Coins) {
                        // add 20 coins to the player
                        for (int i = 0; i < 20; i++) {
                            [self.hud addCoin];
                        }
                    }
                    
                    // play sounds
                    [self runAction:self.soundEffects[@"powerup_collect"]];
                }
            }
        }
    }
    
    // remove colliding objects from game objects and sprite
    for (PSKGameObject *obj in toDelete) {
        [collidables removeObject:obj];
        [obj removeFromParent];
    }
}

#pragma mark - Hazard Collision

- (void)checkForHazardCollision {
    // bools for setting if hit hurt or kill
    BOOL isHurt = NO;
    BOOL isKill = NO;
    
    // if hit nonlethalhazard, setisHurt to YES
    // if hit lethalhazard, set isKill to YES
    for (id object in self.hazards) {
        CGRect rect = [object hazardRect];
        if (CGRectIntersectsRect(rect, self.player.collisionBoundingBox) && self.player.isActive) {
            if ([object isKindOfClass:[PSKNonLethalHazard class]]) {
                // if intersect a non lethal hazard, set isHurt to yes and break
                // to not cause continuous injuries
                isHurt = YES;
                break;
            } else {
                // if intersect a lethal hazard, set isKill to yes and break
                // to not cause continuous deaths
                isKill = YES;
                break;
            }
        }
    }
    
    if (isHurt) {
        // inure the player
        [self.player tookHit:nil];
        [self runAction:self.soundEffects[@"hurt"]];
    } else if (isKill) {
        // kill player
        [self.player killPlayer];
        [self runAction:self.soundEffects[@"hurt"]];
    }
}

#pragma mark - Player Enemy Wall Collision

- (void)checkForPlatformCollision:(PSKPlatform *)platform {
    // if the player is currectly on the platform
    if (_player.onPlatform) {
        CGRect playerRect = [_player collisionBoundingBox];
        CGRect platformRect = [platform collisionBoundingBox];
        if (CGRectIntersectsRect(playerRect, platformRect)) {
            // get the collision box of the intersection
            CGRect intersection = CGRectIntersection(playerRect, platformRect);
            // get the location of the player's footprint
            CGPoint playerFootPoint = CGPointMake(_player.position.x, _player.position.y - playerRect.size.height / 2);
            if (_player.velocity.y < 0 && playerFootPoint.y > platform.position.y) {
                // if the player is falling (means is on top since gravity is pulling down)
                // and player is actually above
                
                // update the desired position to be directly on top of the platform
                _player.desiredPosition = CGPointMake(_player.desiredPosition.x,
                                                      _player.desiredPosition.y + intersection.size.height);
                // set onPlatform and onGround to YES and the velocity's y to 0
                _player.onPlatform = YES;
                _player.onGround = YES;
                [_player setVelocity:CGPointMake(_player.velocity.x, 0.0)];
                
                // add the platform's velocity to the player's desired position
                _player.desiredPosition = CGPointAdd(_player.desiredPosition,platform.velocity);
            }
        }
        
        // set the player's position and return
        _player.position = _player.desiredPosition;
        return;
    }
    
    // get the player and platform rectangles
    CGRect playerRect = [_player collisionBoundingBox];
    CGRect platformRect = [platform collisionBoundingBox];
    
    if (CGRectIntersectsRect(playerRect, platformRect)) {
        // if intersect, get the intersection size and the player's footprint
        CGRect intersection = CGRectIntersection(playerRect, platformRect);
        CGPoint playerFootPoint = CGPointMake(_player.position.x,
                                              _player.position.y - playerRect.size.height / 2);
        if (_player.velocity.y < 0 && playerFootPoint.y > platform.position.y) {
            // if the player is falling down onto the platform and the player is above
            // set the player to directly above
            _player.desiredPosition = CGPointMake(_player.desiredPosition.x,
                                                  _player.desiredPosition.y + intersection.size.height);
            // set onPlatform and onGround to YES
            _player.onPlatform = YES;
            _player.onGround = YES;
            // set the player's velocity's y to 0.0
            [_player setVelocity:CGPointMake(_player.velocity.x, 0.0)];
            
            // add the platform's velocity to the player's position
            _player.desiredPosition = CGPointAdd(_player.desiredPosition,platform.velocity);
        }
    }
    
    // set the player's position
    _player.position = _player.desiredPosition;
}

- (void)enemyCheckForAndResolveTwoTileCollisions:(PSKCharacter *)character {
    // set to not onGround and not onWall
    character.onGround = NO;
    character.onWall = NO;
    
    // if Hound, check for collision with wall layer and the enemy exclusive collision layer
    if ([character isKindOfClass:[PSKHound class]]) {
        [self checkForAndResolveTwoTileWideCollisions:character forLayer:self.walls];
        [self checkForAndResolveTwoTileWideCollisions:character forLayer:self.enemy_collide];
        return;
    }
    
    // if player and is not on slope, check for wall collisions and then slope
    if ([character isKindOfClass:[GPlayer class]] && ![(GPlayer*)character onSlope]) {
        [self checkForAndResolveTwoTileCollisions:character forLayer:self.walls];
        [self checkForPlayerSlopeCollision];
    } else if ([character isKindOfClass:[GPlayer class]])
        // otherwise check straight for slope collision
        [self checkForPlayerSlopeCollision];
    
    // if any type of enemy
    if ([character isKindOfClass:[PSKEnemy class]]) {
        [self checkForAndResolveTwoTileCollisions:character forLayer:self.walls];
        [self checkForAndResolveTwoTileCollisions:character forLayer:self.enemy_collide];
    }
}

- (void)checkForPlayerSlopeCollision {
    // indicator if has hit slope
    BOOL hasHitSlope = NO;
    
    // loop through for slope increasing from left to right
    for (SlopeObject *value in self.slopes) {
        // player is going right (climbing)
        if (CGRectIntersectsRect([value rect], self.player.collisionBoundingBox) &&
            self.player.velocity.y <= 0 && !self.player.flipX && value.isUp) {
            
            // get rectangle, and calculate xOffset from the right edge
            CGRect rect = [value rect];
            CGFloat xDiff = (self.player.desiredPosition.x + self.player.collisionBoundingBox.size.width/2) - rect.origin.x;
            
            // apply to the y
            [self applySlopeCalculations:xDiff upOrDown:value.isUp slope:rect];
            
            // set hasHitSlope to YES and store into lastHitSlope
            hasHitSlope = YES;
            lastHitSlope = [value rect];
        }
        
        // player is going left (descending)
        if (CGRectIntersectsRect([value rect], self.player.collisionBoundingBox) &&
            self.player.velocity.y <= 0 && self.player.flipX && value.isUp) {
            
            // get rectangle, and calculate xOffset from the right edge
            CGRect rect = [value rect];
            CGFloat xDiff = (self.player.desiredPosition.x + self.player.collisionBoundingBox.size.width/2) - rect.origin.x;
            
            // apply to the y
            [self applySlopeCalculations:xDiff upOrDown:value.isUp slope:rect];
            
            // set hasHitSlope to YES and store into lastHitSlope
            hasHitSlope = YES;
            lastHitSlope = [value rect];
        }
    }
    
    // loop through for slope decreasing from left to right
    for (SlopeObject *value in self.slopes) {
        if (CGRectIntersectsRect([value rect], self.player.collisionBoundingBox) &&
            self.player.velocity.y <= 0 && self.player.flipX && !value.isUp) {
            
            // get rectangle, and calculate xOffset from the left edge
            CGRect rect = [value rect];
            CGFloat xDiff = (self.player.desiredPosition.x - self.player.collisionBoundingBox.size.width/2) - rect.origin.x;
            
            // apply to the y
            [self applySlopeCalculations:xDiff upOrDown:value.isUp slope:rect];
            
            // set hasHitSlope to YES and store into lastHitSlope
            hasHitSlope = YES;
            lastHitSlope = [value rect];
        }
        
        if (CGRectIntersectsRect([value rect], self.player.collisionBoundingBox) &&
            self.player.velocity.y <= 0 && !self.player.flipX && !value.isUp) {
            
            // get rectangle, and calculate xOffset from the left edge
            CGRect rect = [value rect];
            CGFloat xDiff = (self.player.desiredPosition.x - self.player.collisionBoundingBox.size.width/2) - rect.origin.x;
            
            // apply to the y
            [self applySlopeCalculations:xDiff upOrDown:value.isUp slope:rect];
            
            // set hasHitSlope to YES and store into lastHitSlope
            hasHitSlope = YES;
            lastHitSlope = [value rect];
        }
    }
    
    if (!hasHitSlope) {
        // if didn't hit but was previously on
        if ([self.player onSlope]) {
            // get the tile of the rectangle
            CGRect r = lastHitSlope;
            CGPoint point = CGPointMake(r.origin.x + 16, r.origin.y + 16);
            CGPoint slopeTile = [self.map tileCoordForPosition:point];
            
            // get the tile to the right and check if player is climbing
            CGPoint sideTile = CGPointMake(slopeTile.x + 1, slopeTile.y);
            if ([self.walls tileGIDAtTileCoord:sideTile] != 0 && !self.player.flipX && self.player.velocity.y <= 0) {
                
                // intentionally set the player to that tile to override slope collision checks
                CGRect re = [self.map tileRectFromTileCoords:sideTile];
                CGPoint p = CGPointMake(re.origin.x,
                                        re.origin.y + 32 + self.player.collisionBoundingBox.size.height/2);
                
                self.player.desiredPosition = p;
                self.player.velocity = CGPointMake(self.player.velocity.x, 0.0);
                self.player.position = self.player.desiredPosition;
            }
            
            // get the tile to the left and check if player is descending
            CGPoint otherTile = CGPointMake(slopeTile.x - 1, slopeTile.y);
            if ([self.walls tileGIDAtTileCoord:otherTile] != 0 && self.player.flipX && self.player.velocity.y <= 0) {
                // intentionally write player to that tile to override slope collision checks.
                CGRect re = [self.map tileRectFromTileCoords:otherTile];
                
                CGPoint p = CGPointMake(re.origin.x + 16,
                                        re.origin.y + 32 + self.player.collisionBoundingBox.size.height/2);
                
                self.player.desiredPosition = p;
                self.player.velocity = CGPointMake(self.player.velocity.x, 0.0);
                self.player.position = self.player.desiredPosition;
            }
        }
        
        // set to not on slope
        [self.player setOnSlope:NO];
    }
}

- (void)applySlopeCalculations:(CGFloat)xDiff upOrDown:(BOOL)isUp slope:(CGRect)rect {
    CGPoint p;
    if (isUp) {
        // if player is going up, add 1/2 size + xOffset to the rect's y
        p = CGPointMake(self.player.desiredPosition.x,
                        rect.origin.y + xDiff + self.player.collisionBoundingBox.size.height/2);
    } else if (!isUp) {
        // if player is going down, add 1/2 size + (32-xOffset) to the rect's y since x and y are reversed
        p = CGPointMake(self.player.desiredPosition.x,
                        rect.origin.y + (32 - xDiff) + self.player.collisionBoundingBox.size.height/2);
    }
    
    // update position
    self.player.desiredPosition = p;
    self.player.position = self.player.desiredPosition;
    
    // set on slope, on ground and velocity's y to 0
    [self.player setOnSlope:YES];
    [self.player setOnGround:YES];
    [self.player setVelocity:CGPointMake(self.player.velocity.x, 0)];
}

- (void)checkForAndResolveTwoTileCollisions:(PSKCharacter *)character forLayer:(TMXLayer *)layer {
    // c array with bottom, up, left, right, tleft, tright, bleft, bright
    NSInteger indices[10] = {10, 1, 3, 5, 6, 8, 0, 2, 9, 11};
    
    // loop through c array, 8 times
    for (NSUInteger i = 0; i < 10; i++) {
        // retrieve tileindex at index
        NSInteger tileIndex = indices[i];
        
        // get the character's bounding box
        CGRect characterRect = [character collisionBoundingBox];
        
        // get tile coord for position
        CGPoint characterCoord = [self.map tileCoordForPosition:CGPointMake(character.position.x,
                                             character.position.y - character.collisionBoundingBox.size.height / 2 + 5)];
        // calculate the correct tile location using the tileindex
        CGPoint tileCoord;
        switch (tileIndex) {
            case 10:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(0, 1));
                break;}
            case 1:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(0, -2));
                break;}
            case 3:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-1, -1));
                break;}
            case 5:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, -1));
                break;}
            case 6:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-1, 0));
                break;}
            case 8:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, 0));
                break;}
            case 0:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-1, -2));
                break;}
            case 2:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, -2));
                break;}
            case 9:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-1, 1));
                break;}
            case 11:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, 1));
                break;}
            default:
                break;
        }
        
        // get the tile GID
        NSInteger gid = [layer tileGIDAtTileCoord:tileCoord];
        
        // if an actual tile, gid is not 0
        if (gid != 0) {
            
            // get the cgrect for the tile at the tilcoord position
            CGRect tileRect = [self.map tileRectFromTileCoords:tileCoord];
            
            if (CGRectIntersectsRect(characterRect, tileRect)) {
                CGRect intersection = CGRectIntersection(characterRect, tileRect);
                
                // utilizing tileindex, decide on how to resolve collision
                if (tileIndex == 10) {
                    //tile is directly below the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x,
                                                            character.desiredPosition.y + intersection.size.height);
                    
                    // reset velocity to 0 and on ground
                    character.velocity = CGPointMake(character.velocity.x, 0.0);
                    character.onGround = YES;
                } else if (tileIndex == 1) {
                    //tile is directly above the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x,
                                                            character.desiredPosition.y - intersection.size.height);
                    
                    // if the tileGID on the meta_layer is not 0 (something there)
                    if ([self.meta_layer tileGIDAtTileCoord:tileCoord] != 0) {
                        // get the dictionary of properties at that coordinate
                        NSDictionary *dictionary = [self.map propertiesForGid:[self.meta_layer tileGIDAtTileCoord:tileCoord]];
                        // if tile at top is player_destroyable
                        if ([dictionary[@"PDestroyable"] intValue] == 1) {
                            // remove tiles at coord
                            [self.walls removeTileAtCoord:tileCoord];
                            [self.meta_layer removeTileAtCoord:tileCoord];
                            
                            // if there is enemy above it, kill it
                            CGPoint coord = CGPointMake(tileCoord.x, tileCoord.y - 1);
                            CGRect box = [self.map tileRectFromTileCoords:coord];
                            for (PSKEnemy *enemy in self.enemies) {
                                if (CGRectIntersectsRect(box, enemy.collisionBoundingBox)) {
                                    [enemy changeState:kStateDead];
                                }
                            }
                            
                            // get the GID at the current coord, add score
                            NSInteger g = [self.enemy_collide tileGIDAtTileCoord:tileCoord];
                            [self.hud addScore:100];
                            // set enemy exclusive collide to the tile directly above and remove the current one
                            [self.enemy_collide setTileGIDAt:coord gid:g];
                            [self.enemy_collide removeTileAtCoord:tileCoord];
                        } else if ([dictionary[@"Drops"] intValue] == 1 && [character isKindOfClass:[GPlayer class]]) {
                            // spin a random number about shouldCreate powerup or not
                            int x = arc4random_uniform(13);
                            BOOL shouldCreate = NO;
                            switch (x) {
                                case 0:
                                    shouldCreate = YES;
                                    break;
                                case 3:
                                    shouldCreate = YES;
                                    x = 1;
                                    break;
                                case 6:
                                    shouldCreate = YES;
                                    x = 2;
                                    break;
                                case 9:
                                    shouldCreate = YES;
                                    x = 3;
                                    break;
                                default:
                                    break;
                            }
                            
                            // get the tile GID at the corner of the map
                            CGPoint t = CGPointMake(0, 0);
                            int gid = (int)[self.walls tileGIDAtTileCoord:t];
                            
                            // if should create
                            if (shouldCreate) {
                                // create the powerup, and set the position
                                PSKPowerLiteral *p = [[PSKPowerLiteral alloc] initWithState:x];
                                p.anchorPoint = CGPointMake(0, 0);
                                p.zPosition = 250;
                                
                                // add the powerup + map
                                CGPoint tc = CGPointMake(tileCoord.x, tileCoord.y - 1);
                                [p setPosition:[self.map tileRectFromTileCoords:tc].origin];
                                [self.powerups addObject:p];
                                [self.map addChild:p];
                                
                                // remove tile at coord and set the location on the wall layer to the gid
                                [self.meta_layer removeTileAtCoord:tileCoord];
                                [self.walls setTileGIDAt:tileCoord gid:gid];
                                
                                // play sound
                                [self runAction:self.soundEffects[@"powerup_appear"]];
                            } else {
                                // remove tile at coord and set the location on the wall layer to the gid
                                // add coin collected to player
                                [self.meta_layer removeTileAtCoord:tileCoord];
                                [self.walls setTileGIDAt:tileCoord gid:gid];
                                [self.hud addCoin];
                                
                                [self runAction:self.soundEffects[@"coin_collect"]];
                            }
                        }
                    }
                    
                    // reset upwards/downwards
                    character.velocity = CGPointMake(character.velocity.x, 0.0);
                } else if (tileIndex == 3 || tileIndex == 6) {
                    //tile is left of the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x + intersection.size.width,
                                                            character.desiredPosition.y);
                    
                    character.onWall = YES;
                    character.velocity = CGPointMake(0.0, character.velocity.y);
                } else if (tileIndex == 5 || tileIndex == 8) {
                    //tile is right of the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x - intersection.size.width,
                                                            character.desiredPosition.y);
                    
                    character.onWall = YES;
                    character.velocity = CGPointMake(0.0, character.velocity.y);
                } else {
                    // if the collision is wider then is higher
                    if (intersection.size.width > intersection.size.height) {
                        //tile is diagonal, but resolving collision vertically
                        CGFloat resolutionHeight;
                        // if below, add, else subtract
                        if (tileIndex > 7) {
                            resolutionHeight = intersection.size.height;
                            
                            // if not still jumping, reset velocity
                            if (character.velocity.y < 0) {
                                character.velocity = CGPointMake(character.velocity.x, 0.0);
                                character.onGround = YES;
                            }
                        } else {
                            resolutionHeight = -intersection.size.height;
                            
                            // if hit ceiling, reset velocity
                            if (character.velocity.y > 0) {
                                character.velocity = CGPointMake(character.velocity.x, 0.0);
                            }
                        }
                        character.desiredPosition = CGPointMake(character.desiredPosition.x,
                                                                character.desiredPosition.y + resolutionHeight);
                    } else {
                        //tile is diagonal, but resolving horizontally
                        CGFloat resolutionWidth;
                        // if left, add, else subtract
                        if (tileIndex == 0 || tileIndex == 9) {
                            resolutionWidth = intersection.size.width;
                        } else {
                            resolutionWidth = -intersection.size.width;
                        }
                        
                        character.desiredPosition = CGPointMake(character.desiredPosition.x + resolutionWidth,
                                                                character.desiredPosition.y);
                        
                        if (tileIndex == 9 || tileIndex == 11) {
                            character.onWall = YES;
                        }
                        character.velocity = CGPointMake(0.0, character.velocity.y);
                    }
                }
            }
        }
            
        // update character position
        character.position = character.desiredPosition;
    }
}

- (void)checkForAndResolveTwoTileWideCollisions:(PSKCharacter *)character forLayer:(TMXLayer *)layer {
    // c array with bottom, up, left, right, tleft, tright, bleft, bright
    NSInteger indices[10] = {10, 9, 1, 2, 4, 7, 0, 8, 3, 11};
    
    // loop through c array, 8 times
    for (NSUInteger i = 0; i < 10; i++) {
        // retrieve tileindex at index
        NSInteger tileIndex = indices[i];
        
        // get the character's bounding box
        CGRect characterRect = [character collisionBoundingBox];
        
        // get tile coord for position
        CGPoint characterCoord = [self.map tileCoordForPosition:CGPointMake(character.position.x + character.size.width/2 - 5,
                                                                            character.position.y)];
        // calculate the correct tile location using the tileindex
        CGPoint tileCoord;
        switch (tileIndex) {
            case 10:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(0, 1));
                break;}
            case 9:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-1, 1));
                break;}
            case 1:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, -1));
                break;}
            case 2:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(0, -1));
                break;}
            case 4:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-2, 0));
                break;}
            case 7:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, 0));
                break;}
            case 0:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-2, -1));
                break;}
            case 8:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(-2, 1));
                break;}
            case 3:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, -1));
                break;}
            case 11:{
                tileCoord = CGPointAdd(characterCoord, CGPointMake(1, 1));
                break;}
            default:
                break;
        }
        
        // get the tile GID
        NSInteger gid = [layer tileGIDAtTileCoord:tileCoord];
        
        // if an actual tile, gid is not 0
        if (gid != 0) {
            // get the cgrect for the tile at the tilcoord position
            CGRect tileRect = [self.map tileRectFromTileCoords:tileCoord];
            
            // check if the rects intersect and store the intersection point
            if (CGRectIntersectsRect(characterRect, tileRect)) {
                CGRect intersection = CGRectIntersection(characterRect, tileRect);
                
                // utilizing tileindex, decide on how to resolve collision
                if (tileIndex == 10 || tileIndex == 9) {
                    //tile is directly below the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x,
                                                            character.desiredPosition.y + intersection.size.height);
                    
                    // reset velocity to 0 and on ground
                    character.velocity = CGPointMake(character.velocity.x, 0.0);
                    character.onGround = YES;
                } else if (tileIndex == 1 || tileIndex == 2) {
                    //tile is directly above the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x,
                                                            character.desiredPosition.y - intersection.size.height);
                    // reset upwards/downwards
                    character.velocity = CGPointMake(character.velocity.x, 0.0);
                } else if (tileIndex == 4) {
                    //tile is left of the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x + intersection.size.width,
                                                            character.desiredPosition.y);
                    
                    character.onWall = YES;
                    character.velocity = CGPointMake(0.0, character.velocity.y);
                } else if (tileIndex == 7) {
                    //tile is right of the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x - intersection.size.width,
                                                            character.desiredPosition.y);
                    
                    character.onWall = YES;
                    character.velocity = CGPointMake(0.0, character.velocity.y);
                } else {
                    // if the collision is wider then is higher
                    if (intersection.size.width > intersection.size.height) {
                        //tile is diagonal, but resolving collision vertically
                        CGFloat resolutionHeight;
                        // if below, add, else subtract
                        if (tileIndex > 7) {
                            resolutionHeight = intersection.size.height;
                            
                            // if not still jumping, reset velocity
                            if (character.velocity.y < 0) {
                                character.velocity = CGPointMake(character.velocity.x, 0.0);
                                character.onGround = YES;
                            }
                        } else {
                            resolutionHeight = -intersection.size.height;
                            
                            // if hit ceiling, reset velocity
                            if (character.velocity.y > 0) {
                                character.velocity = CGPointMake(character.velocity.x, 0.0);
                            }
                        }
                        character.desiredPosition = CGPointMake(character.desiredPosition.x,
                                                                character.desiredPosition.y + resolutionHeight);
                    } else {
                        //tile is diagonal, but resolving horizontally
                        CGFloat resolutionWidth;
                        // if left, add, else subtract
                        if (tileIndex == 0 || tileIndex == 8) {
                            resolutionWidth = intersection.size.width;
                        } else {
                            resolutionWidth = -intersection.size.width;
                        }
                        
                        character.desiredPosition = CGPointMake(character.desiredPosition.x + resolutionWidth,
                                                                character.desiredPosition.y);
                        
                        if (tileIndex == 8 || tileIndex == 11) {
                            character.onWall = YES;
                        }
                        character.velocity = CGPointMake(0.0, character.velocity.y);
                    }
                }
            }
        }
        
        // update character position
        character.position = character.desiredPosition;
    }
}

#pragma mark - Single Tile Collisions

- (void)checkForAndResolveOneTileCollisions:(PSKCharacter *)character {
    // set onGround + onWall
    // check collision for two layers
    character.onGround = NO;
    character.onWall = NO;
    
    // check with walls layer and exclusive enemy_collide layer
    [self checkCollisionForLayer:self.walls character:character];
    [self checkCollisionForLayer:self.enemy_collide character:character];
}

- (void)checkCollisionForLayer:(TMXLayer *)layer character:(PSKCharacter *)character {
    NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
    
    for (NSUInteger i = 0; i < 8; i++) {
        NSInteger tileIndex = indices[i];
        
        CGRect characterRect = [character collisionBoundingBox];
        CGPoint characterCoord = [self.walls coordForPoint:character.position];
        
        NSInteger tileColumn = tileIndex % 3;
        NSInteger tileRow = tileIndex / 3;
        CGPoint tileCoord = CGPointMake(characterCoord.x + (tileColumn - 1), characterCoord.y + (tileRow - 1));
        
        NSInteger gid = [layer tileGIDAtTileCoord:tileCoord];
        if (gid != 0) {
            CGRect tileRect = [self.map tileRectFromTileCoords:tileCoord];
            if (CGRectIntersectsRect(characterRect, tileRect)) {
                CGRect intersection = CGRectIntersection(characterRect, tileRect);
                if (tileIndex == 7) {
                    //tile is directly below the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x, character.desiredPosition.y + intersection.size.height);
                    character.velocity = CGPointMake(character.velocity.x, 0.0);
                    character.onGround = YES;
                } else if (tileIndex == 1) {
                    //tile is directly above the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x, character.desiredPosition.y - intersection.size.height);
                    character.velocity = CGPointMake(character.velocity.x, 0.0);
                } else if (tileIndex == 3) {
                    //tile is left of the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x + intersection.size.width, character.desiredPosition.y);
                    character.onWall = YES;
                    character.velocity = CGPointMake(0.0, character.velocity.y);
                } else if (tileIndex == 5) {
                    //tile is right of the character
                    character.desiredPosition = CGPointMake(character.desiredPosition.x - intersection.size.width, character.desiredPosition.y);
                    character.onWall = YES;
                    character.velocity = CGPointMake(0.0, character.velocity.y);
                } else {
                    if (intersection.size.width > intersection.size.height) {
                        //tile is diagonal, but resolving collision vertically
                        CGFloat resolutionHeight;
                        if (tileIndex > 4) {
                            resolutionHeight = intersection.size.height;
                            if (character.velocity.y < 0) {
                                character.velocity = CGPointMake(character.velocity.x, 0.0);
                                character.onGround = YES;
                            }
                        } else {
                            resolutionHeight = -intersection.size.height;
                            if (character.velocity.y > 0) {
                                character.velocity = CGPointMake(character.velocity.x, 0.0);
                            }
                        }
                        character.desiredPosition = CGPointMake(character.desiredPosition.x, character.desiredPosition.y + resolutionHeight);
                    } else {
                        //tile is diagonal, but resolving horizontally
                        CGFloat resolutionWidth;
                        if (tileIndex == 6 || tileIndex == 0) {
                            resolutionWidth = intersection.size.width;
                        } else {
                            resolutionWidth = -intersection.size.width;
                        }
                        character.desiredPosition = CGPointMake(character.desiredPosition.x + resolutionWidth, character.desiredPosition.y);
                        
                        if (tileIndex == 6 || tileIndex == 8) {
                            character.onWall = YES;
                        }
                        
                        character.velocity = CGPointMake(0.0, character.velocity.y);
                    }
                }
            }
        }
        
        character.position = character.desiredPosition;
    }
}

#pragma mark - player to enemy collisions

- (void)checkForEnemyCollisions:(PSKEnemy *)enemy {
    // check if can collide
    if (enemy.isActive && self.player.isActive) {
        if (CGRectIntersectsRect(self.player.collisionBoundingBox, enemy.collisionBoundingBox)) {
            // if intersect, create the location of the foot of the player
            CGPoint playerFootPoint = CGPointMake(self.player.position.x,
                                                  self.player.position.y - self.player.collisionBoundingBox.size.height / 2);
            // if the player is falling down on top of the enemy
            if (self.player.velocity.y < 0 && playerFootPoint.y > enemy.position.y) {
                // apply the bounce to the player
                [self.player bounce];
                
                // hit the enemy, play sound and add score
                [enemy tookHit:self.player];
                [self runAction:self.soundEffects[@"jump_kill"]];
                [self.hud addScore:200];
                
                // if the enemy is dead, add a coin
                if (enemy.characterState == kStateDead) {
                    [self.hud addCoin];
                    [self runAction:self.soundEffects[@"coin_collect"]];
                }
            } else {
                if ([enemy isKindOfClass:[PSKKnight class]]) {
                    // if the enemy is a knight
                    PSKKnight *k = (PSKKnight *)enemy;
                    if (!k.isCowering) {
                        // if the knight is up and walking, then injure the player
                        [self.player tookHit:enemy];
                        [self runAction:self.soundEffects[@"hurt"]];
                    }
                } else {
                    // injure the player
                    [self.player tookHit:enemy];
                    [self runAction:self.soundEffects[@"hurt"]];
                }
            }
        }
    }
}

#pragma mark - Pause Game

- (void)pauseGame:(BOOL)shouldPlayMusic {
    // set gameRunning to NO
    self.gameRunning = NO;
    
    // set alpha to 50%, userInteraction not
    [self.gameNode setAlpha:0.5];
    [self.hud setUserInteractionEnabled:NO];
    
    // set alpha to 50%
    [self.hud setAlpha:0.5];
    
    // if there isn't a pause/win/lose
    if (!self.pause && !self.win && !self.lose) {
        // create the pause screen and position it
        self.pause = [[PSKPauseScreen alloc] initWithSize:self.size hud:self.hud];
        self.pause.zPosition = 500000;
        [self.pause setDelegate:self];
        [self addChild:self.pause];
    }
    
    // if shouldPlayMusic, pausebackground music
    if (shouldPlayMusic) {
        [[SKTAudio sharedInstance] pauseBackgroundMusic];
        [self runAction:self.soundEffects[@"pause"]];
    }
}

- (void)winGamePause {
    // set game running to No and set alpha to 0.5
    self.gameRunning = NO;
    [self.gameNode setAlpha:0.5];
    [self.hud setUserInteractionEnabled:NO];
    [self.hud setAlpha:0.5];
    
    // create the win screen
    self.win = [[PSKWinScreen alloc] initWithScreen:self size:self.size hud:self.hud];
    self.win.zPosition = 10000;
    [self.win setDelegate:self];
    [self addChild:self.win];
}

- (void)loseGamePause {
    // set game to losing
    self.gameRunning = NO;
    [self.gameNode setAlpha:0.5];
    
    // create the lose screen
    self.lose = [[PSKLoseScreen alloc] initWithSize:self.size hud:self.hud];
    self.lose.zPosition = 100000;
    [self.lose setDelegate:self];
    [self addChild:self.lose];
    
    // pause background music + run life_death music
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
    [self runAction:self.soundEffects[@"life_death"]];
}

- (void)unpauseGame {
    // unpause the game
    self.gameRunning = YES;
    [self.gameNode setAlpha:1.0];
    [self.hud setAlpha:1.0];
    [self.hud setUserInteractionEnabled:YES];
    
    // resume background music
    [[SKTAudio sharedInstance] resumeBackgroundMusic];
    
    // remove pause
    [self destroyPause];
}

- (void)restartLose {
    // remove lose
    [self destroyLose];
    
    // if hasreachedcheckpoint
    if (self.hasReachedCheckpoint) {
        // normally restart with checkpoint
        [self restartGameEvaluationCheckpoint];
    } else {
        // normally restart
        [self restart];
    }
}

- (void)levelListLose {
    // remove lose and show level listing
    [self destroyLose];
    [self levelList];
}

- (void)restartGameEvaluationCheckpoint {
    // get the current level and reset it again
    int current = [[PSKGameManager sharedManager] levelUID];
    [[PSKGameManager sharedManager] setLevelUID:current];
    
    // set arrows + life + coins and save the player
    [[PSKGameManager sharedManager] setArrowsToPlayerStats:self.hud.arrowAmount];
    [[PSKGameManager sharedManager] setLifeToPlayer:[[PSKGameManager sharedManager] getLives]];
    [[PSKGameManager sharedManager] setCoinsToPlayerSTats:self.hud.getCoin];
    [[PSKGameManager sharedManager] savePlayer];
    
    // unload the scene and call delegate method
    [self unloadScene];
    [self.sceneDelegate representSceneFromCheckpoint];
}

- (void)restart {
    // get the current level and reset it again
    int current = [[PSKGameManager sharedManager] levelUID];
    [[PSKGameManager sharedManager] setLevelUID:current];
    
    // set arrows + life + coins and save the player
    [[PSKGameManager sharedManager] setArrowsToPlayerStats:self.hud.arrowAmount];
    [[PSKGameManager sharedManager] setLifeToPlayer:[[PSKGameManager sharedManager] getLives]];
    [[PSKGameManager sharedManager] setCoinsToPlayerSTats:self.hud.getCoin];
    [[PSKGameManager sharedManager] savePlayer];
    
    // unload the scene and call delegate method
    [self unloadScene];
    [self.sceneDelegate representThisScene];
}

- (void)levelListWin {
    // retrieve level ID
    int luid = [[PSKGameManager sharedManager] levelUID];
    
    if (luid < 3) {
        // if the luid is less than 3, means there is one more level in current world
        // add 1 to the luid and call levelList method
        [[PSKGameManager sharedManager] setLevelUID:luid + 1];
        [self levelList];
    } else {
        // get the world ID
        int wuid = [[PSKGameManager sharedManager] worldUID];
        
        // if the wuid is less than 5 (one more world left)
        // increase the wuid
        if (wuid < 5) {
            wuid++;
        }
        
        // set the wuid
        [[PSKGameManager sharedManager] setWorldUID:wuid];
        
        // unload the scene and dismiss Scene with unlock
        [self unloadScene];
        [self.sceneDelegate dismissSceneWithUnlock:YES];
    }
}

- (void)levelList {
    // pause background
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
    
    // save all information about the player
    [[PSKGameManager sharedManager] setArrowsToPlayerStats:self.hud.arrowAmount];
    [[PSKGameManager sharedManager] setLifeToPlayer:[[PSKGameManager sharedManager] getLives]];
    [[PSKGameManager sharedManager] setCoinsToPlayerSTats:self.hud.getCoin];
    [[PSKGameManager sharedManager] savePlayer];
    
    // unload the scene
    [self unloadScene];
    
    // dismiss scene without unlock
    [self.sceneDelegate dismissSceneWithUnlock:NO];
}

- (void)nextScene {
    // get current level id
    int current = [[PSKGameManager sharedManager] levelUID];
    
    // if the current level is less than 3
    if (current < 3) {
        // set the level id
        [[PSKGameManager sharedManager] setLevelUID:current+1];
        
        // unload scene + present the next scene
        [self unloadScene];
        [self.sceneDelegate presentNextScene];
    } else {
        // otherwise, increment the wuid
        // get the world ID
        int wuid = [[PSKGameManager sharedManager] worldUID];
        
        // if the wuid is less than 5 (one more world left)
        // increase the wuid
        if (wuid < 5) {
            wuid++;
        }
        [[PSKGameManager sharedManager] setWorldUID:wuid];
        
        // unload the scene
        // change the world with an unlock
        [self unloadScene];
        // dismiss Scene with unlock = YES
        [self.sceneDelegate dismissSceneWithUnlock:YES];
    }
}

#pragma mark - Exit

- (void)checkForExit {
    // get distance between player to exit
    CGFloat distanceToExit = CGPointDistance(self.player.position, self.exitPoint);
    
    // if distance is less than 100
    if (distanceToExit < 100) {
        // set the gameRunning to NO
        self.gameRunning = NO;
        
        // get the current level id
        int current = [[PSKGameManager sharedManager] levelUID];
        
        // if the current level is less than 3, unlock the level
        Level *l;
        if (current < 3) {
            // fetch the level with the current id + 1 and unlock it
            l = [[PSKGameManager sharedManager] retrieveLevelWithUID:current+1 worldUID:[[PSKGameManager sharedManager] worldUID]];
            [l setIsUnlocked:[NSNumber numberWithBool:YES]];
        }
        
        // retrieve the current level
        l = [[PSKGameManager sharedManager] retrieveLevelWithUID:current worldUID:[[PSKGameManager sharedManager] worldUID]];
        
        // set level's first gathered
        if (self.firstGot) {
            [l setFirstGathered:[NSNumber numberWithBool:YES]];
            [self.hud addScore:1000];
        }
        
        // set level's second gathered
        if (self.secondGot) {
            [l setSecondGathered:[NSNumber numberWithBool:YES]];
            [self.hud addScore:1000];
        }
        
        // set level's third gathered
        if (self.thirdGot) {
            [l setThirdGathered:[NSNumber numberWithBool:YES]];
            [self.hud addScore:1000];
        }
        
        // add the score due to time
        float x = 10 * self.hud.currentTime;
        [self.hud addScore:roundf(x)];
        
        // add the score due to life
        float life = 200 * (self.player.life/100);
        [self.hud addScore:roundf(life)];
        
        // if score is higher, set the level's score
        if (self.hud.getScore > [l.score intValue]) {
            [l setScore:[NSNumber numberWithInt:self.hud.getScore]];
        }
        
        // save all the data, player + level + world
        [[PSKGameManager sharedManager] setArrowsToPlayerStats:self.hud.arrowAmount];
        [[PSKGameManager sharedManager] setLifeToPlayer:[[PSKGameManager sharedManager] getLives]];
        [[PSKGameManager sharedManager] setCoinsToPlayerSTats:self.hud.getCoin];
        [[PSKGameManager sharedManager] savePlayer];
        
        // pause background music + play level_clear
        [[SKTAudio sharedInstance] pauseBackgroundMusic];
        [self runAction:self.soundEffects[@"level_clear"]];
        
        // show win screen
        [self winGamePause];
    }
}

- (void)loseGame {
    // disable user interaction
    [self.hud setUserInteractionEnabled:NO];
    [self.hud setAlpha:0.5];
    
    // subtract a life, set arrows + coins and save player
    [[PSKGameManager sharedManager] setLifeToPlayer:[[PSKGameManager sharedManager] getLives]-1];
    [[PSKGameManager sharedManager] setArrowsToPlayerStats:self.hud.arrowAmount];
    [[PSKGameManager sharedManager] setCoinsToPlayerSTats:self.hud.getCoin];
    [[PSKGameManager sharedManager] savePlayer];
    
    // if no lives left
    if ([[PSKGameManager sharedManager] getLives] <= 0) {
        // pause music + run game_over
        [[SKTAudio sharedInstance] pauseBackgroundMusic];
        [self runAction:self.soundEffects[@"game_over"]];
        
        // show alert view that says that you ran out of lives
        [[[UIAlertView alloc] initWithTitle:@"Game Over!" message:@"You've ran out of lives. Your game data is now being reset." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        // show lose game screen
        [self loseGamePause];
    }
}

- (void)dealloc {
    NSLog(@"DEALLOCATED!");
}

- (void)unloadScene {
    // chain all unrelease into the autoreleasepool
    @autoreleasepool {
        // remove the parallax
        [[self.gameNode childNodeWithName:@"parallax"] removeFromParent];
        
        // stop countdowning
        [self removeActionForKey:@"Countdown"];
        self.countdownTimerAction = nil;
        
        // remove all views + array + player ' map
        [self destroyViews];
        [self removeAllArrays];
        [self removePlayerAndMap];
        
        // remove all sound effects
        [self.soundEffects removeAllObjects];
        self.soundEffects = nil;
        
        // remove all actions + children
        [self removeAllActions];
        [self removeAllChildren];
        
        // remove game node
        [self.gameNode removeFromParent];
        self.gameNode = nil;
        
        // release all holds on atlases
        self.atlas = nil;
        self.sceneAtlas = nil;
    }
}

- (void)removePlayerAndMap {
    // unload player and remove it
    [self.player unload];
    [self.player removeFromParent];
    self.player = nil;
    
    // remove all children and actions
    [self.map removeAllChildren];
    [self.map removeAllActions];
    
    // remove the map, walls, meta_layer
    [self.map removeFromParent];
    [self.walls removeFromParent];
    [self.meta_layer removeFromParent];
    [self.enemy_collide removeFromParent];
    
    // release all references
    self.map = nil;
    self.walls = nil;
    self.meta_layer = nil;
    self.enemy_collide = nil;
    self.sceneAtlas = nil;
}

- (void)removeAllArrays {
    // call unload on each array
    [self unloadArray:self.platforms];
    [self unloadArray:self.arrows];
    [self unloadArray:self.enemies];
    [self unloadArray:self.coins];
    [self unloadArray:self.arrowables];
    [self unloadArray:self.enemies];
    [self unloadArray:self.hazards];
    [self unloadArray:self.powerups];
    [self unloadArray:self.uniqueCollectables];
    
    // remove the checkpoint
    [self.checkpoint removeFromParent];
    self.checkpoint = nil;
}

- (void)unloadArray:(NSMutableArray *)array {
    // loop through the entire array
    for (NSUInteger i = 0; i < [array count]; i++) {
        id obj = array[0];
        
        // if the object is of PSKGameObject
        if ([obj isKindOfClass:[PSKGameObject class]]) {
            // unload it and remove it from parent
            [(PSKGameObject *)obj unload];
            [obj removeFromParent];
            obj = nil;
        }
    }
    
    // remove all objects
    [array removeAllObjects];
    array = nil;
}

- (void)destroyViews {
    // destroy HUD/Win/Lose/Pause
    [self destroyHUD];
    [self destroyWin];
    [self destroyLose];
    [self destroyPause];
}

- (void)destroyHUD {
    // if hud exists,unload it and remove fromParent
    if (self.hud) {
        self.hud.delegate = nil;
        [self.hud unload];
        [self.hud removeFromParent];
        self.hud = nil;
    }
}

- (void)destroyWin {
    // if win exists, unload it and remove from scene
    if (self.win) {
        self.win.delegate = nil;
        [self.win removeAllChildren];
        [self.win removeAllActions];
        [self.win removeFromParent];
        self.win = nil;
    }
}

- (void)destroyLose {
    // if lose exists, unload it and remove from scene
    if (self.lose) {
        self.lose.delegate = nil;
        [self.lose removeAllChildren];
        [self.lose removeAllActions];
        [self.lose removeFromParent];
        self.lose = nil;
    }
}

- (void)destroyPause {
    // if pause exists, unload it and remove from scene
    if (self.pause) {
        self.pause.delegate = nil;
        [self.pause removeAllChildren];
        [self.pause removeAllActions];
        [self.pause removeFromParent];
        self.pause = nil;
    }
}

#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // reset the Data
    [self unloadScene];
    [self.sceneDelegate resetData];
}

#pragma mark - Description

- (NSString *)description {
    // print contents of all the states of the node
    NSLog(@"%@",self.gameNode);
    
    NSLog(@"%@",self.map);
    NSLog(@"%@",self.walls);
    NSLog(@"%@",self.meta_layer);
    
    NSLog(@"%@",_checkpoint);
    NSLog(@"%@",_hud); // r
    NSLog(@"%@",_win); // r
    NSLog(@"%@",_lose); // r
    NSLog(@"%@",_pause); // r
    
    NSLog(@"%@",_player);
    
    NSLog(@"%@",_platforms);
    NSLog(@"%@",_hazards); // r
    NSLog(@"%@",_enemies);
    NSLog(@"%@",_arrows); // r
    NSLog(@"%@",_coins); // r
    NSLog(@"%@",_arrowables); // r
    NSLog(@"%@",_uniqueCollectables); // r
    NSLog(@"%@",_powerups); // r
    
    NSLog(@"%@",_countdownTimerAction);
    
    return @"";
}

@end
