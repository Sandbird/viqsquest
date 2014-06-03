//
//  PSKDescScene.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/7/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKDescScene.h"

#import "PSKGameManager.h"

@implementation PSKDescScene

- (id)initWithSize:(CGSize)size {
    if ((self = [super initWithSize:size])) {
        PSKGameManager *mang = [PSKGameManager sharedManager];
        
        // show the world, level node
        SKLabelNode *worldLevel = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        worldLevel.zPosition = 1000;
        worldLevel.fontSize = 60.0;
        worldLevel.text = [NSString stringWithFormat:@"%d - %d",[mang worldUID],[mang levelUID]];
        worldLevel.position = CGPointMake(size.width/2, size.height/2);
        
        // show number of lives
        SKLabelNode *lives = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        lives.zPosition = 1000;
        lives.fontSize = 40.0;
        lives.text = [NSString stringWithFormat:@"%d Lives",[mang getLives]];
        lives.position = CGPointMake(size.width/2, (size.height/2) - 59);
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:size];
        sprite.zPosition = 100;
        [sprite setAnchorPoint:CGPointMake(0, 0)];
        [sprite setPosition:CGPointMake(0, 0)];
        
        [self addChild:sprite];
        [self addChild:worldLevel];
        [self addChild:lives];
    }
    
    return self;
}

@end
