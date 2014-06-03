//
//  ParallaxNode.h
//  PocketCyclopsSK
//
//  Created by Jake Gundersen on 10/19/13.
//  Copyright (c) 2013 Jacob Gundersen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface JLGParallaxNode : SKNode

@property (nonatomic, strong) SKNode *rootNode;
- (void)update;
- (void)addChild:(SKNode*)child z:(CGFloat)zOrder parallaxRatio:(CGPoint)ratio positionOffset:(CGPoint)offset;

@end