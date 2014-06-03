//
//  MainMenuViewController.m
//  SKPocketCyclops
//
//  Created by Jacob Gundersen on 4/20/12.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SKTAudio.h"

#import "PSKAppDelegate.h"
#import "PSKGameManager.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // if no lives left, call the returnToMM with no sender
    if ([[PSKGameManager sharedManager] getLives] <= 0) {
        [self returnToMM:nil];
    }
}

- (IBAction)returnToMM:(UIStoryboardSegue *)sender {
    // get refernece to App Delegate
    // reset the core data stack
    PSKAppDelegate *ap = (PSKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [ap resetCoreDataStack];
    
    // set PSKGameManager's context and reinitialize the player
    [[PSKGameManager sharedManager] setContext:ap.managedObjectContext];
    [[PSKGameManager sharedManager] initializePlayerID];
}

@end
