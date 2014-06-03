//
//  PSKWinScreen.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/12/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKWinScreen.h"
#import "PSKLevelScene.h"

#import "PSKGameManager.h"
#import "PSKHUDNode.h"
#import "PSKSharedTextureCache.h"

@interface PSKWinScreen ()

// create references to all the sprite nodes and label nodes
@property (nonatomic, strong) SKSpriteNode *restartNode;
@property (nonatomic, strong) SKSpriteNode *levelListNode;
@property (nonatomic, strong) SKSpriteNode *resumeNode;

@property (nonatomic, strong) SKLabelNode *worldNode;
@property (nonatomic, strong) SKLabelNode *scoreNode;
@property (nonatomic, strong) SKLabelNode *liveNode;

@property (nonatomic, strong) SKSpriteNode *firstNode;
@property (nonatomic, strong) SKSpriteNode *secondNode;
@property (nonatomic, strong) SKSpriteNode *thirdNode;

@end

@implementation PSKWinScreen

- (id)initWithScreen:(PSKLevelScene *)scene size:(CGSize)size hud:(PSKHUDNode *)hud {
    if ((self = [super init])) {
        // enable user interation
        [self setUserInteractionEnabled:YES];
        
        // get the texture atlas
        SKTextureAtlas *atlas = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
        
        // create restart node and position it
        self.restartNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"restart.png"]];
        [self.restartNode setPosition:CGPointMake((size.width *3/4) - 35, (size.height * 1/4))];
        self.restartNode.zPosition = 100;
        [self addChild:self.restartNode];
        
        // create level List node and position it
        self.levelListNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"list.png"]];
        [self.levelListNode setPosition:CGPointMake((size.width *1/4) + 35, (size.height * 1/4))];
        self.levelListNode.zPosition = 100;
        [self addChild:self.levelListNode];
        
        // create next level node and position it
        self.resumeNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"resume.png"]];
        [self.resumeNode setPosition:CGPointMake(size.width/2, (size.height * 1/4))];
        self.resumeNode.zPosition = 100;
        [self addChild:self.resumeNode];
        
        // get level and world
        int wuid = [[PSKGameManager sharedManager] worldUID];
        int luid = [[PSKGameManager sharedManager] levelUID];
        
        // set the world's information such as worldID and levelID
        self.worldNode = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        [self.worldNode setFontSize:36];
        [self.worldNode setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self.worldNode setPosition:CGPointMake(size.width/2, (size.height - 30))];
        [self.worldNode setText:[NSString stringWithFormat:@"World %d - %d",wuid,luid]];
        [self.worldNode setZPosition:100];
        [self addChild:self.worldNode];
        
        // show the score
        self.scoreNode = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        [self.scoreNode setFontSize:30];
        [self.scoreNode setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self.scoreNode setPosition:CGPointMake(size.width/2, (size.height - 60))];
        [self.scoreNode setText:[NSString stringWithFormat:@"Score: %d",[hud getScore]]];
        [self.scoreNode setZPosition:100];
        [self addChild:self.scoreNode];
        
        // show how many lives left
        self.liveNode = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        [self.liveNode setFontSize:30];
        [self.liveNode setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self.liveNode setPosition:CGPointMake(size.width/2, (size.height - 90))];
        [self.liveNode setText:[NSString stringWithFormat:@"Lives: %d",[[PSKGameManager sharedManager] getLives]]];
        [self.liveNode setZPosition:100];
        [self addChild:self.liveNode];
        
        // depending on the unique items got, show the correct image
        if (scene.firstGot)
            self.firstNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldExisting.png"]];
        else
            self.firstNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldMissing.png"]];
        
        if (scene.secondGot)
            self.secondNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldExisting.png"]];
        else
            self.secondNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldMissing.png"]];
        
        if (scene.thirdGot)
            self.thirdNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldExisting.png"]];
        else
            self.thirdNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldMissing.png"]];
        
        // position those images
        [self.secondNode setPosition:CGPointMake(size.width/2, size.height/2)];
        [self.firstNode setPosition:CGPointSubtract(self.secondNode.position, CGPointMake(70, 0))];
        [self.thirdNode setPosition:CGPointAdd(self.secondNode.position, CGPointMake(70, 0))];
        
        // set the zpostiion and add teo winNode
        self.firstNode.zPosition = 100;
        self.secondNode.zPosition = 100;
        self.thirdNode.zPosition = 100;
        [self addChild:self.firstNode];
        [self addChild:self.secondNode];
        [self addChild:self.thirdNode];
        
        // add background "backdrop"
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(size.width/2, size.height)];
        sprite.zPosition = 0;
        [sprite setPosition:CGPointMake(size.width/2, size.height/2)];
        [self addChild:sprite];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        // if hit restart
        if ([self.restartNode containsPoint:location]) {
            // delegate restart method
            [self.delegate restart];
        } else if ([self.levelListNode containsPoint:location]) {
            // if hit next. add 1 to luid
            // return to levelList
            [self.delegate levelListWin];
        } else if ([self.resumeNode containsPoint:location]) {
            // delegate next scene
            [self.delegate nextScene];
        }
    }
}

@end
