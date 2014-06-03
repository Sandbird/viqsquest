//
//  PSKPowerLiteral.m
//  SKPocketCyclops
//
//  Created by William Zhang on 5/8/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKPowerLiteral.h"

@implementation PSKPowerLiteral

- (id)initWithState:(Powerups)powerup {
    // depending on the powerup, set the corresponding filepath
    NSString *filename;
    switch (powerup) {
        case FullHealth:
            filename = @"FullHealth.png";
            break;
        case Add1Health:
            filename = @"PlusHealth.png";
            break;
        case Plus10Arrows:
            filename = @"Arrowcollect.png";
            break;
        case Plus20Coins:
            filename = @"CoinPlus.png";
            break;
        default:
            break;
    }
    
    // retrieve atlas of all the sprites already initialized
    // create the object with the [filename] and set the powerup state
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    if ((self = [super initWithTexture:[atlas textureNamed:filename]])) {
        self.powerup = powerup;
    }
    
    return self;
}

@end
