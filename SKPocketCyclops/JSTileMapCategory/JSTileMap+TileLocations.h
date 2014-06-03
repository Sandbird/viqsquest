//
//  JSTileMap+TileLocations.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "JSTileMap.h"

@interface JSTileMap (TileLocations)

// calculate rect from tilecoords
- (CGRect)tileRectFromTileCoords:(CGPoint)tileCoords;

// calculate wall at position
- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord;

// get a tile coord for a given position
- (CGPoint)tileCoordForPosition:(CGPoint)position;

@end


@interface TMXLayer (TileLocations)

// category on TMXLayer, get tileGID
- (NSInteger)tileGIDAtTileCoord:(CGPoint)point;

@end