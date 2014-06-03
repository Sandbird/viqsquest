//
//  PSKViewController.h
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "PSKLevelScene.h"

#import "LevelViewController.h"

@interface PSKGameViewController : UIViewController <SceneDelegate>

// currentLevel
@property (nonatomic, assign) NSUInteger currentLevel;

// weak reference to LevelViewController
@property (nonatomic, weak) LevelViewController *level;

@end
