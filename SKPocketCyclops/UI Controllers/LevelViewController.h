//
//  LevelViewController.h
//  SKPocketCyclops
//
//  Created by William Zhang on 4/30/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Level.h"

@interface LevelViewController : UIViewController <UIScrollViewDelegate>

// pass in worldUID
- (Level *)objectAtWorld:(int)luid;
@property (nonatomic) int worldUID;

@end
