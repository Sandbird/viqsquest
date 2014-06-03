//
//  PSKGameObject.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKGameObject.h"
#import "PSKSharedTextureCache.h"

@implementation PSKGameObject

// override init
- (id)initWithTexture:(SKTexture *)texture {
    if (self = [super initWithTexture:texture]) {
        
    }
    
    return self;
}

- (void)setFlipX:(BOOL)flipX {
    // flip orizontally depending on boolean value
    if (flipX) {
        self.xScale = -fabs(self.xScale);
    } else {
        self.xScale = fabs(self.xScale);
    }
    
    _flipX = flipX;
}

// since flipping and size setting may have unintended consequences
// overrite the setsize
- (void)setSize:(CGSize)size {
    // preserve state of flipping
    if (!self.flipX) {
        [super setSize:size];
    } else {
        [super setSize:CGSizeMake(-size.width, size.height)];
    }
}

- (SKAction *)loadAnimationFromPlist:(NSString *)animationName forClass:(NSString *)className {
    // load correct plist for each aniamtion
    NSString *path = [[NSBundle mainBundle] pathForResource:className ofType:@"plist"];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // retrieve dictionary for each animation
    NSDictionary *animationSettings = plistDictionary[animationName];
    // calculate the delay
    float delayPerUnit = [animationSettings[@"delay"] floatValue];
    
    // get each frame and store it into an array
    NSString *animationFrames = animationSettings[@"animationFrames"];
    NSArray *animationFrameNumbers = [animationFrames componentsSeparatedByString:@","];
    
    // retreive texture and add to an array
    SKTextureAtlas *atlas = [[PSKSharedTextureCache sharedCache] atlasNamed:@"sprites"];
    NSMutableArray *frames = [NSMutableArray array];
    for (NSString *frameNumber in animationFrameNumbers) {
        NSString *frameName = [NSString stringWithFormat:@"%@%@.png",className,frameNumber];
        SKTexture *frame = [atlas textureNamed:frameName];
        [frames addObject:frame];
    }
    
    // return the action
    return [SKAction animateWithTextures:frames timePerFrame:delayPerUnit resize:YES restore:NO];
}

// remove all actions and children
- (void)unload {
    [self removeAllActions];
    [self removeAllChildren];
}

@end
