//
//  PSKBowman.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/5/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKEnemy.h"

@protocol PSKBowmanFire <NSObject>

// delegate method fired
- (void)bowmanFired:(PSKEnemy *)turret;

@end

@interface PSKBowman : PSKEnemy

// store reference to arm and the delegate
@property (nonatomic, strong) SKSpriteNode *arm;
@property (nonatomic, assign) id<PSKBowmanFire> delegate;

// init
- (id)initWithTexture:(SKTexture *)name;

// update + collision
- (void)update:(NSTimeInterval)dt;
- (CGRect)collisionBoundingBox;

@end
