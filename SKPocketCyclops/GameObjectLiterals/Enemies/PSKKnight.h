//
//  PSKKnight.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/5/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKEnemy.h"

@interface PSKKnight : PSKEnemy

// detect if in phase 1 or phase 2
// creation
@property (nonatomic, assign) BOOL isCowering;
- (id)initWithTexture:(SKTexture *)name;

@end
