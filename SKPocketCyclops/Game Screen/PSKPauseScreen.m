//
//  PSKPauseScreen.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/8/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKPauseScreen.h"
#import "PSKSharedTextureCache.h"
#import "PSKGameManager.h"
#import "PSKHUDNode.h"

#import "SKTAudio.h"

@interface PSKPauseScreen ()

// create references to objects
@property (nonatomic, strong) SKSpriteNode *restartNode;
@property (nonatomic, strong) SKSpriteNode *levelListNode;
@property (nonatomic, strong) SKSpriteNode *resumeNode;
@property (nonatomic, strong) SKSpriteNode *pauseNode;

@property (nonatomic, strong) SKLabelNode *worldNode;
@property (nonatomic, strong) SKLabelNode *scoreNode;

@end

@implementation PSKPauseScreen

- (id)initWithSize:(CGSize)size hud:(PSKHUDNode *)hud {
    if (self = [super init]) {
        // set user interaction
        [self setUserInteractionEnabled:YES];
        
        // set atlas
        SKTextureAtlas *atlas = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
        
        // create restart node and position
        self.restartNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"restart.png"]];
        [self.restartNode setPosition:CGPointMake((size.width *3/4) - 35, (size.height * 1/4))];
        self.restartNode.zPosition = 100;
        [self addChild:self.restartNode];
        
        // create level list and position
        self.levelListNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"list.png"]];
        [self.levelListNode setPosition:CGPointMake((size.width *1/4) + 35, (size.height * 1/4))];
        self.levelListNode.zPosition = 100;
        [self addChild:self.levelListNode];
        
        // create resume and position
        self.resumeNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"resume.png"]];
        [self.resumeNode setPosition:CGPointMake(size.width/2, (size.height * 1/4))];
        self.resumeNode.zPosition = 100;
        [self addChild:self.resumeNode];
        
        // get world and level IDs
        int wuid = [[PSKGameManager sharedManager] worldUID];
        int luid = [[PSKGameManager sharedManager] levelUID];
        
        // show world information such as level + world
        self.worldNode = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        [self.worldNode setFontSize:36];
        [self.worldNode setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self.worldNode setPosition:CGPointMake(size.width/2, (size.height *3/4))];
        [self.worldNode setText:[NSString stringWithFormat:@"World %d - %d",wuid,luid]];
        [self.worldNode setZPosition:100];
        [self addChild:self.worldNode];
        
        // show the current score up to this point
        self.scoreNode = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        [self.scoreNode setFontSize:30];
        [self.scoreNode setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self.scoreNode setPosition:CGPointMake(size.width/2, (size.height/2))];
        [self.scoreNode setText:[NSString stringWithFormat:@"Score: %d",[hud getScore]]];
        [self.scoreNode setZPosition:100];
        [self addChild:self.scoreNode];
        
        // create pause node and set the position
        SKTexture *tex = [atlas textureNamed:[[SKTAudio sharedInstance] isMuted] ? @"mute.png" : @"unmute.png"];
        self.pauseNode = [SKSpriteNode spriteNodeWithTexture:tex];
        [self.pauseNode setPosition:CGPointMake(80, size.height - 80)];
        self.pauseNode.zPosition = 100;
        [self addChild:self.pauseNode];
        
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
        if ([self.restartNode containsPoint:location]) {
            // if restart hit, restart
            [self.delegate restart];
        } else if ([self.levelListNode containsPoint:location]) {
            // if level list, show level listing
            [self.delegate levelList];
        } else if ([self.resumeNode containsPoint:location]) {
            // if resume hit unpause
            [self.delegate unpauseGame];
        } else if ([self.pauseNode containsPoint:location]) {
            // mute/unmute button
            // get and reverse current state of audio
            BOOL audio = ![[SKTAudio sharedInstance] isMuted];
            
            // use the state of bool to generate correct method
            SEL sel = audio ? @selector(muteAudio) : @selector(unmuteAudio);
            // call that method (warning is not important, since the selector is known (static))
            [[SKTAudio sharedInstance] performSelector:sel];
            
            // get texture atlas and set the atlas
            SKTextureAtlas *atlas = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
            [self.pauseNode setTexture:[atlas textureNamed:audio ? @"mute.png" : @"unmute.png"]];
        }
    }
}

@end
