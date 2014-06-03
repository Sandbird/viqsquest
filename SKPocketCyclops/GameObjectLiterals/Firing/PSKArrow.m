//
//  PSKArrow.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/1/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKArrow.h"
#import "SKTUtils.h"

@implementation PSKArrow

- (void)update:(NSTimeInterval)dt {
    // add the velocity to the position and update
    self.position = CGPointAdd(self.position, self.velocity);
}

- (CGRect)collisionBoundingBox {
    return self.frame;
}

+ (BOOL)checkForAndResolveCollisions:(TMXLayer *)layer arrow:(PSKArrow *)arrow map:(JSTileMap *)map {
    // retrieve the meta layer which dictates interactable values
    TMXLayer *meta = [map layerNamed:@"meta_layer"];
    
    // c array with bottom, up, left, right, tleft, tright, bleft, bright relative to the arrow
    // although arrow is 2 tiles wide, we check in a box to check collision properly
    NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
    
    // loop through c array, 8 times
    for (NSUInteger i = 0; i < 8; i++) {
        // retrieve tileindex at index
        NSInteger tileIndex = indices[i];
        
        // get the character's bounding box
        CGRect characterRect = [arrow collisionBoundingBox];
        
        // get tile coord for position
        CGPoint characterCoord = [layer coordForPoint:arrow.position];
        
        // calculate the correct tile location using the tileindex
        // retrieve the tilecoord with tilecoord
        NSInteger tileColumn = tileIndex % 3;
        NSInteger tileRow = tileIndex / 3;
        CGPoint tileCoord = CGPointMake(characterCoord.x + (tileColumn - 1), characterCoord.y + (tileRow - 1));
        
        // get the tile GID
        NSInteger gid = [layer tileGIDAtTileCoord:tileCoord];
        
        // if an actual tile, gid is not 0
        if (gid != 0) {
            // get the cgrect for the tile at the tilcoord position
            CGRect tileRect = [map tileRectFromTileCoords:tileCoord];
            
            // check if the rects intersect and store the intersection point
            if (CGRectIntersectsRect(characterRect, tileRect)) {
                
                // if the tile can be destroyed by player destroy it.
                if ([meta tileGIDAtTileCoord:tileCoord] != 0) {
                    NSDictionary *properties = [map propertiesForGid:[meta tileGIDAtTileCoord:tileCoord]];
                    if ([properties[@"ADestroyable"] intValue] == 1 && !arrow.isFiredByTurret) {
                        [layer removeTileAtCoord:tileCoord];
                        [meta removeTileAtCoord:tileCoord];
                    }
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}


@end
