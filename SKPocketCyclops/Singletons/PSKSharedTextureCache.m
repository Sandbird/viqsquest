//
//  PSKSharedTextureCache.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKSharedTextureCache.h"

@interface PSKSharedTextureCache ()

// store all textures
@property (nonatomic, strong) NSMutableDictionary *textureAtlases;

@end

@implementation PSKSharedTextureCache

+ (PSKSharedTextureCache *)sharedCache {
    // guarentee creation once
    static dispatch_once_t pred;
    static PSKSharedTextureCache *sharedCache;
    dispatch_once(&pred, ^{
        sharedCache = [PSKSharedTextureCache new];
    });
    
    return sharedCache;
}

// alloc texturesatlas dictionary on creation
- (id)init {
    if ((self = [super init])) {
        self.textureAtlases = [NSMutableDictionary dictionary];
    }
    
    return self;
}

// set the texture atlas to a key in the dictioanry
// load all the assets of the textureatlas into memory right away
- (void)addTextureAtlas:(SKTextureAtlas *)atlas name:(NSString *)name {
    [self.textureAtlases setObject:atlas forKey:name];
    [atlas preloadWithCompletionHandler:^{
        NSLog(@"Preload Complete!");
    }];
}

// return the atlas with a given name (key)
// all textures are already loaded
- (SKTextureAtlas *)atlasNamed:(NSString *)name {
    return self.textureAtlases[name];
}

// remove the atlas from the dictionary
// if all other references are destroyed, atlas should deallocate
- (void)removeAtlas:(NSString *)atlas {
    [self.textureAtlases removeObjectForKey:atlas];
}

@end
