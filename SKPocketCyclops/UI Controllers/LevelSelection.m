//
//  LevelSelection.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/19/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "LevelSelection.h"

@implementation LevelSelection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // position + create all required labels and buttons and images
        self.worldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 161, 21)];
        [self.worldLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.worldLabel];
        
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -21, 161, 21)];
        [self.scoreLabel setTextAlignment:NSTextAlignmentCenter];
        [self.scoreLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:self.scoreLabel];
        
        self.selectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectionButton setFrame:CGRectMake(0, 0, 161, 161)];
        [self addSubview:self.selectionButton];
        
        self.firstSword = [[UIImageView alloc] initWithFrame:CGRectMake(-24.5, 91, 70, 70)];
        self.secondSword = [[UIImageView alloc] initWithFrame:CGRectMake(45.5, 91, 70, 70)];
        self.thirdSword = [[UIImageView alloc] initWithFrame:CGRectMake(115.5, 91, 70, 70)];
        
        // use @autoreleasepool to immediately deallocate any objects created
        @autoreleasepool {
            NSString *string = [[NSBundle mainBundle] pathForResource:@"swordGoldMissing" ofType:@"png"];
            NSData *data = [NSData dataWithContentsOfFile:string];
            UIImage *image = [UIImage imageWithData:data];
            
            [self.firstSword setImage:image];
            [self.secondSword setImage:image];
            [self.thirdSword setImage:image];
        }
        
        [self addSubview:self.firstSword];
        [self addSubview:self.secondSword];
        [self addSubview:self.thirdSword];
    }
    return self;
}

@end
