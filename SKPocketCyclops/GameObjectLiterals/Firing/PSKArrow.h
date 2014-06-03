//
//  PSKArrow.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/1/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKGameObject.h"

#import "JSTileMap.h"
#import "JSTileMap+TileLocations.h"

@interface PSKArrow : PSKGameObject

// desired position + velocity
@property (nonatomic, assign) CGPoint velocity;

// who fired the arrow
@property (nonatomic, assign) BOOL isFiredByTurret;

// update and bounding box
- (void)update:(NSTimeInterval)dt;
- (CGRect)collisionBoundingBox;

// check if an arrow intersects a layer on a given map
+ (BOOL)checkForAndResolveCollisions:(TMXLayer *)layer arrow:(PSKArrow *)arrow map:(JSTileMap *)map;

@end
