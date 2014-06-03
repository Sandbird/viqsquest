
//
//  PSKAppDelegate.m
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKAppDelegate.h"
#import "SKTAudio.h"

#import "PSKSharedTextureCache.h"
#import "PSKGameManager.h"

@implementation PSKAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     Create all necessary managers. GameManager for retrieving and saving necessary data.
     Set the context and then initalize the player object.
     
     PSKSharedTextureCache for maintaining a strong reference to the texture atlas (graphics) throughout the execution in which I can also remove/add at will
     Begin playing the theme music
    */
    PSKGameManager *g = [PSKGameManager sharedManager];
    [g setContext:_managedObjectContext];
    [g initializePlayerID];
    
    PSKSharedTextureCache *s = [PSKSharedTextureCache sharedCache];
    [s addTextureAtlas:[SKTextureAtlas atlasNamed:@"sprites"] name:@"sprites"];
    
    [[SKTAudio sharedInstance] playBackgroundMusic:@"MFTheme.mp3"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[SKTAudio sharedInstance] resumeBackgroundMusic];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[SKTAudio sharedInstance] resumeBackgroundMusic];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data stack

- (void)resetCoreDataStack {
    // reset all context values
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
    
    // remove the already existing sqlite file at the document path
    // write the sqlite in project to the document
    NSURL *storeURL = [(NSURL *)[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AlastairQuestData.sqlite"];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"AlastairQuestData" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
    }
    
    // recreate the persistentstorecoordinator
    error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AlastairQuestData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // if the file does not exist at path, save sqlite data to file and
    // write the sqlite file to path
    NSURL *storeURL = [(NSURL *)[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AlastairQuestData.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"AlastairQuestData" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
