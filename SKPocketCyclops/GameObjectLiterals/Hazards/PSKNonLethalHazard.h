//
//  PSKNonLethalHazard.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/12/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSKNonLethalHazard : NSObject

// creates a nonlethalhazard given a rectangel
// accessor + creator
@property (nonatomic, assign) CGRect hazardRect;
- (id)initWithRect:(CGRect)rect;

@end
