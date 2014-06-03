//
//  PSKAppDelegate.h
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface PSKAppDelegate : UIResponder <UIApplicationDelegate> {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

/*
 Declare variables to hold core data necessary objects and accessory methods.
 Core data is a persistence store which I preload in a sqlite file.
 I then use Core Data APIs to retrieve certain necessary objects.
*/
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;
- (void)resetCoreDataStack;

@property (strong, nonatomic) UIWindow *window;

@end
