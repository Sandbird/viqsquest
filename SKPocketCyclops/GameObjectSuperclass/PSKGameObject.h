//
//  PSKGameObject.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PSKGameObject : SKSpriteNode

@property (nonatomic, assign) BOOL flipX;

// load an animation from a plist given a name and a class
- (SKAction *)loadAnimationFromPlist:(NSString *)animationName forClass:(NSString *)className;

// unload and create with a texture
- (void)unload;
- (id)initWithTexture:(SKTexture *)texture;

@end
