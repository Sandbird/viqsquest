//
//  JSTileMap+TileLocations.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "JSTileMap+TileLocations.h"

@implementation JSTileMap (TileLocations)

- (CGRect)tileRectFromTileCoords:(CGPoint)tileCoords {
    // get the level height in pixels
    CGFloat levelHeightInPixels = self.mapSize.height * self.tileSize.height;
    
    // calculate x from tilcoord * width
    // invert y, SK top, T bot, add 1 to y since tile are 0 based
    CGPoint origin = CGPointMake(tileCoords.x * self.tileSize.width,
                                 levelHeightInPixels - (tileCoords.y + 1) * self.tileSize.height);
    
    // return rectangle from origin and tilesize
    return CGRectMake(origin.x, origin.y, self.tileSize.width, self.tileSize.height);
}

- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord {
    // return yes if tile exists at the tilecoord in layer: walls
    // else return no
    TMXLayer *layer = [self layerNamed:@"walls"];
    NSInteger gid = [layer tileGIDAtTileCoord:tileCoord];
    return (gid != 0);
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    // get x coordinate by dividing position's x by tilesize width
    // get y coordinate by dividing map size by position's y (inverted tile system) by tilesize height
    int x = position.x / self.tileSize.width;
    int y = ((self.mapSize.height * self.tileSize.height) - position.y) / self.tileSize.height;
    return CGPointMake(x, y);
}

@end

@implementation TMXLayer (TileLocations)

// return tile gid from point at tilecoords
- (NSInteger)tileGIDAtTileCoord:(CGPoint)point {
    return [self.layerInfo tileGidAtCoord:point];
}

@end