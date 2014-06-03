//
//  PSKPowerup.h
//  SKPocketCyclops
//
//  Created by William Zhang on 5/8/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKGameObject.h"

@interface PSKPowerup : PSKGameObject

// enum of potential powerups
typedef NS_ENUM(NSInteger, Powerups) {
    FullHealth,
    Add1Health,
    Plus10Arrows,
    Plus20Coins,
};

// stores the type of powerup
@property (nonatomic, assign) Powerups powerup;

@end