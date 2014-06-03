//
//  LevelSelection.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/19/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelSelection : UIView

// levelLabel and button
@property (nonatomic, strong) UILabel *worldLabel;
@property (nonatomic, strong) UIButton *selectionButton;

// score
@property (nonatomic, strong) UILabel *scoreLabel;

// references to the UC images
@property (nonatomic, strong) UIImageView *firstSword;
@property (nonatomic, strong) UIImageView *secondSword;
@property (nonatomic, strong) UIImageView *thirdSword;

@end
