//
//  PSKViewController.m
//  SKPocketCyclops
//
//  Created by Jake Gundersen on 10/26/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "PSKGameViewController.h"

#import "PSKGameManager.h"
#import "PSKDescScene.h"

#define kSize CGSizeMake(568, 320)

@interface PSKGameViewController () {
    // timer + atlas
    NSTimer *timer;
    SKTextureAtlas *atlas;
}

// array of observers and a strong reference to the level scene
@property (nonatomic, strong) NSMutableArray *observers;
@property (nonatomic, strong) PSKLevelScene *scene;

@end

@implementation PSKGameViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setupObservers];
}

- (void)viewDidLoad {
    // perform load in background
    [self performSelectorInBackground:@selector(load) withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    // unmute theme music
    [[SKTAudio sharedInstance] unmuteAudio];
}

- (void)viewWillAppear:(BOOL)animated {
    // if scene does not exist, create description display
    // chain this + viewDidLoad
    if (!self.scene)
        [self createDescriptionDisplay];
}

- (void)createDescriptionDisplay {
    // create description display + present it
    SKView *skView = (SKView *)self.view;
    
    PSKDescScene *scene = [[PSKDescScene alloc] initWithSize:kSize];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene transition:[SKTransition crossFadeWithDuration:1.0]];
}

- (void)load {
    // set show fps and node count
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // get the atlas
    atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    
    // create the level scene with size, and levelsender + atlas
    PSKLevelScene *scene = [[PSKLevelScene alloc] initWithSize:kSize sender:self.level atlas:atlas];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // set delegate to self + store reference
    self.scene = scene;
    scene.sceneDelegate = self;
    
    // 3 second countdown
    dispatch_async(dispatch_get_main_queue(), ^{
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startTheGame:) userInfo:nil repeats:NO];
    });
}

- (void)loadAndRewritePlayerPosition {
    // load the level
    [self load];
    
    // set player's position to the checkpoint
    [self.scene setPlayerPositionToCheckpoint];
}

- (void)startTheGame:(NSTimer *)timer {
    // call scene's start Game and present the scene
    [self.scene startTheGame];
    [(SKView *)self.view presentScene:self.scene transition:[SKTransition crossFadeWithDuration:1.0]];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)setupObservers {
    self.observers = [NSMutableArray array];

    // add observer for when application entered the background
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // pause all draws on the scene
        SKView *skView = (SKView *)self.view;
        skView.paused = YES;
    }];
    [self.observers addObject:observer];
  
    // add observer for when application is no longer active (phone call/background/notification center)
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // pause all draws + music + pause game with no music
        SKView *skView = (SKView *)self.view;
        [[SKTAudio sharedInstance] pauseBackgroundMusic];
        [self.scene pauseGame:NO];
        skView.paused = YES;
    }];
    [self.observers addObject:observer];
  
    // add observer when application enters foreground from background
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // unpause draws + resume background music
        SKView *skView = (SKView *)self.view;
        skView.paused = NO;
        
        [[SKTAudio sharedInstance] resumeBackgroundMusic];
    }];
    [self.observers addObject:observer];
    
    // add observer when application rebecomes active (phone call/notification center)
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // unpause draws + background music
        SKView *skView = (SKView *)self.view;
        skView.paused = NO;
        
        [[SKTAudio sharedInstance] resumeBackgroundMusic];
    }];
    [self.observers addObject:observer];
}

- (void)dealloc {
    // remove all observers
    for (id observer in self.observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

- (void)dismissSceneWithUnlock:(BOOL)unlock {
    // remove all observers
    for (id observer in self.observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    
    self.observers = nil;
    
    // remove scene +delegate
    self.scene.sceneDelegate = nil;
    self.scene = nil;
    
    // if a world is unlocked
    if (unlock) {
        // if wuid is less than 5
        int wuid = [[PSKGameManager sharedManager] worldUID];
        if (wuid < 5) {
            // get that World and unlock it
            World *w = [[PSKGameManager sharedManager] retrieveWorldWithUID:wuid];
            [w setIsUnlocked:[NSNumber numberWithBool:YES]];
            
            // get first level of that world and unlock it
            Level *lev = [[PSKGameManager sharedManager] retrieveLevelWithUID:1 worldUID:wuid];
            [lev setIsUnlocked:[NSNumber numberWithBool:YES]];
            
            // save all data
            [[PSKGameManager sharedManager] savePlayer];
            
            // update wuid and luid
            [[PSKGameManager sharedManager] setWorldUID:wuid];
            [[PSKGameManager sharedManager] setLevelUID:1];
        }
        
        // go to world selection
        [self performSegueWithIdentifier:@"unwindToWorld" sender:self];
        return;
    }
    
    // unwind to level selection
    [self performSegueWithIdentifier:@"unwindToLevel" sender:self];
}

- (void)presentNextScene {
    // remove scene + delegate
    self.scene.sceneDelegate = nil;
    self.scene = nil;
    
    // create description and load scene in background
    [self createDescriptionDisplay];
    [self performSelectorInBackground:@selector(load) withObject:nil];
}

- (void)representThisScene {
    // remove scene + delegate
    self.scene.sceneDelegate = nil;
    self.scene = nil;
    
    // create description and load scene in background
    [self createDescriptionDisplay];
    [self performSelectorInBackground:@selector(load) withObject:nil];
}

- (void)resetData {
    // remove all scene and delegate
    self.scene.sceneDelegate = nil;
    self.scene = nil;
    
    // segue back to main menu to wipe data
    [self performSegueWithIdentifier:@"mainMenu" sender:self];
}

- (void)representSceneFromCheckpoint {
    // remvoe sceneDelegate and scene
    self.scene.sceneDelegate = nil;
    self.scene = nil;
    
    // recreate level
    [self createDescriptionDisplay];
    // write the player's position to the checkpoint
    [self performSelectorInBackground:@selector(loadAndRewritePlayerPosition) withObject:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // release all strong references
    atlas = nil;
    self.scene.sceneDelegate = nil;
    self.scene = nil;
}

@end