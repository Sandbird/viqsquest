//
//  SlopeObject.h
//  Vic's Quest
//
//  Created by William Zhang on 5/26/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlopeObject : NSObject

- (id)initWithRect:(CGRect)rect up:(BOOL)isUp;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) BOOL isUp;

@end
