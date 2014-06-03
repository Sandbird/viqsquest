//
//  Level.h
//  AlastairQuestData
//
//  Created by William Zhang on 5/24/14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class World;

@interface Level : NSManagedObject

@property (nonatomic, retain) NSNumber * firstGathered;
@property (nonatomic, retain) NSNumber * isUnlocked;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * secondGathered;
@property (nonatomic, retain) NSNumber * thirdGathered;
@property (nonatomic, retain) NSNumber * timeLimit;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) World *world;

@end
