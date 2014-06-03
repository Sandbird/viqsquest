//
//  PSKPlatform.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/8/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKGameObject.h"

@interface PSKPlatform : PSKGameObject

@property (nonatomic, assign) CGPoint velocity;

// collision + update + initiation
- (id)initWithImageNamed:(SKTexture *)name forPlatformType:(NSString*)pT withSpeed:(CGFloat)speed andDistance:(CGFloat)dTM;
- (CGRect)collisionBoundingBox;
- (void)update:(NSTimeInterval)dt;

@end
