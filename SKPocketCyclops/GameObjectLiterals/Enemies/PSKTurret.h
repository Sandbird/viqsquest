//
//  PSKTurret.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/1/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKEnemy.h"

@protocol PSKTurretFire <NSObject>

// delegate method to know when turret fired
- (void)firedTurret:(PSKEnemy *)turret;

@end

@interface PSKTurret : PSKEnemy

// reference to the arm
@property (nonatomic, strong) SKSpriteNode *arm;

// store whether ground mounted and the rotation for when air mounted
@property (nonatomic, assign) BOOL isGroundMounted;
@property (nonatomic, assign) float rotation;

@property (nonatomic, assign) id<PSKTurretFire> delegate;

// initiation and collision
- (id)initWithTexture:(SKTexture *)name;
- (CGRect)collisionBoundingBox;

@end
