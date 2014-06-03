//
//  PSKLoseScreen.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/9/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKLoseScreen.h"
#import "PSKSharedTextureCache.h"

#import "PSKHUDNode.h"
#import "PSKGameManager.h"

@interface PSKLoseScreen ()

// references to nodes
@property (nonatomic, strong) SKSpriteNode *restartNode;
@property (nonatomic, strong) SKSpriteNode *levelListNode;

@property (nonatomic, strong) SKLabelNode *worldNode;
@property (nonatomic, strong) SKLabelNode *liveNode;

@end

@implementation PSKLoseScreen

- (id)initWithSize:(CGSize)size hud:(PSKHUDNode *)hud {
    if (self = [super init]) {
        // user interaction + atlases
        [self setUserInteractionEnabled:YES];
        SKTextureAtlas *atlas = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
        
        // restart node create and position
        self.restartNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"restart.png"]];
        [self.restartNode setPosition:CGPointMake(size.width/3, (size.height/2) - 70)];
        self.restartNode.zPosition = 100;
        [self addChild:self.restartNode];
        
        // level list node create and position
        self.levelListNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"list.png"]];
        [self.levelListNode setPosition:CGPointMake(size.width *2/3, (size.height/2) - 70)];
        self.levelListNode.zPosition = 100;
        [self addChild:self.levelListNode];
        
        // get level ID and world ID
        int wuid = [[PSKGameManager sharedManager] worldUID];
        int luid = [[PSKGameManager sharedManager] levelUID];
        
        // create worldNode and show world id and level id
        self.worldNode = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        [self.worldNode setFontSize:36];
        [self.worldNode setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self.worldNode setPosition:CGPointMake(size.width/2, (size.height *3/4))];
        [self.worldNode setText:[NSString stringWithFormat:@"World %d - %d",wuid,luid]];
        [self.worldNode setZPosition:100];
        [self addChild:self.worldNode];
        
        // show lives left node
        self.liveNode = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        [self.liveNode setFontSize:30];
        [self.liveNode setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self.liveNode setPosition:CGPointMake(size.width/2, (size.height/2))];
        [self.liveNode setText:[NSString stringWithFormat:@"Lives: %d",[[PSKGameManager sharedManager] getLives]]];
        [self.liveNode setZPosition:100];
        [self addChild:self.liveNode];
        
        // add backdrop
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
        // if tapped restart, restart with loss
        if ([self.restartNode containsPoint:location]) {
            [self.delegate restartLose];
        } else if ([self.levelListNode containsPoint:location]) {
            // if tapped level list, level list with loss
            [self.delegate levelListLose];
        }
    }
}

@end
