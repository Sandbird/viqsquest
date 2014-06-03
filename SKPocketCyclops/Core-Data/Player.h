//
//  Player.h
//  AlastairQuestData
//
//  Created by William Zhang on 5/24/14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player : NSManagedObject

@property (nonatomic, retain) NSNumber * arrowsLeft;
@property (nonatomic, retain) NSNumber * coins;
@property (nonatomic, retain) NSNumber * livesLeft;

@end
