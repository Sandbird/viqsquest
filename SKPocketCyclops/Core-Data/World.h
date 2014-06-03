//
//  World.h
//  AlastairQuestData
//
//  Created by William Zhang on 5/24/14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Level;

@interface World : NSManagedObject

@property (nonatomic, retain) NSNumber * isUnlocked;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *level;
@end

@interface World (CoreDataGeneratedAccessors)

- (void)addLevelObject:(Level *)value;
- (void)removeLevelObject:(Level *)value;
- (void)addLevel:(NSSet *)values;
- (void)removeLevel:(NSSet *)values;

@end
