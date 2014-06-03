//
//  PSKSharedTextureCache.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface PSKSharedTextureCache : NSObject

// return shared
+ (PSKSharedTextureCache *)sharedCache;

// retrieve and set textures
- (void)addTextureAtlas:(SKTextureAtlas *)atlas name:(NSString *)name;
- (SKTextureAtlas *)atlasNamed:(NSString *)name;
- (void)removeAtlas:(NSString *)atlas;

@end
