//
//  LevelViewController.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/30/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "LevelViewController.h"
#import "PSKGameManager.h"
#import "LevelSelection.h"

#import "Level.h"
#import "SKTAudio.h"
#import "PSKGameViewController.h"

@interface LevelViewController ()
@property (nonatomic, strong) NSArray *levelArray;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@end

@implementation LevelViewController
@synthesize levelArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // if any LevelSelection objects already exist, remove them!
    for (UIView *view in self.scroller.subviews) {
        if ([view isKindOfClass:[LevelSelection class]]) {
            [view removeFromSuperview];
        }
    }
    
    // get an array of all the levels for a given world
    levelArray = [[PSKGameManager sharedManager] retrieveAllLevelsForWorldWithUID:self.worldUID];
    
    CGFloat screenWidth = self.view.bounds.size.width;
    
    // use @autoreleasepool for memory purposes
    @autoreleasepool {
        CGRect r;
        // iterate through each object in the levelArray
        for (unsigned int i = 0; i < [levelArray count]; i++) {
            // create instance of LevelSelection
            Level *level = levelArray[i];
            LevelSelection *world = [[LevelSelection alloc] initWithFrame:CGRectMake(0, 0, 161, 161)];
            
            // position LevelSelection based off of which iteration and set the frame accordingly
            r = world.frame;
            CGFloat x = (screenWidth - r.size.width) * 0.5 + screenWidth * i;
            r.origin.x = x;
            r.origin.y = (self.view.bounds.size.height - r.size.height) * 0.5;;
            world.frame = r;
            
            // set the level Name, using font, color and automatic scaling
            world.worldLabel.text = level.name;
            world.worldLabel.textAlignment = NSTextAlignmentCenter;
            [world.worldLabel setFont:[UIFont fontWithName:@"OldeEnglish-Regular" size:50]];
            [world.worldLabel setTextColor:[UIColor whiteColor]];
            [world.worldLabel setAdjustsFontSizeToFitWidth:YES];
            [world.worldLabel setMinimumScaleFactor:0.25];
            
            // set the tag of the selection button and add a target
            world.selectionButton.tag = level.uid.integerValue;
            [world.selectionButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            // retrieve the image for the button and set the SelectionButton's Image
            NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level%d%d",self.worldUID,level.uid.intValue] ofType:@".png"];
            NSData *data = [NSData dataWithContentsOfFile:file];
            UIImage *image = [UIImage imageWithData:data];
            [world.selectionButton setImage:image forState:UIControlStateNormal];
            
            // depending on if the UC is collected or not, retrieve the reference and set it
            file = [[NSBundle mainBundle] pathForResource:@"swordGoldExisting" ofType:@"png"];
            if ([level.firstGathered boolValue]) {
                data = [NSData dataWithContentsOfFile:file];
                UIImage *image = [UIImage imageWithData:data];
                [world.firstSword setImage:image];
            }
            
            if ([level.secondGathered boolValue]) {
                data = [NSData dataWithContentsOfFile:file];
                UIImage *image = [UIImage imageWithData:data];
                [world.secondSword setImage:image];
            }
            
            if ([level.thirdGathered boolValue]) {
                data = [NSData dataWithContentsOfFile:file];
                UIImage *image = [UIImage imageWithData:data];
                [world.thirdSword setImage:image];
            }
            
            // set the score
            world.scoreLabel.text = [NSString stringWithFormat:@"%d",[level.score intValue]];
            
            // if the level is locked, disable it
            if (![level.isUnlocked boolValue]) {
                [world.selectionButton setEnabled:NO];
                [world.selectionButton setAlpha:0.5];
            }
            
            // add it to the scrollview
            [self.scroller addSubview:world];
        }
    }
    
    self.scroller.pagingEnabled = YES;
    [self.pageControl setNumberOfPages:[self.levelArray count]];
    self.scroller.contentSize = CGSizeMake(screenWidth * [self.levelArray count], self.view.bounds.size.height);
    
    [self.scroller setDelegate:self];
}

- (void)buttonTapped:(id)sender {
    // perform segue
    [self performSegueWithIdentifier:@"ToGameView" sender:sender];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToGameView"]) {
        // pause background music, get the destination view controller and set level reference to self
        [[SKTAudio sharedInstance] pauseBackgroundMusic];
        PSKGameViewController *gvc = segue.destinationViewController;
        [gvc setLevel:self];
        
        UIButton *button = (UIButton *)sender;
        gvc.currentLevel = button.tag;
        
        // set the world's UID and and the level's UID
        [[PSKGameManager sharedManager] setWorldUID:self.worldUID];
        [[PSKGameManager sharedManager] setLevelUID:(int)button.tag];
    }
}

- (IBAction)returnToLevelSelection:(UIStoryboardSegue *)segue {
    // reposition current Page and scrollView depending on the level coming back
    self.pageControl.currentPage = [[PSKGameManager sharedManager] levelUID] - 1;
    self.scroller.contentOffset = CGPointMake((self.pageControl.currentPage) * (self.view.frame.size.width), self.scroller.contentOffset.y);
    
    // play theme music
    [[SKTAudio sharedInstance] playBackgroundMusic:@"MFTheme.mp3"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // update the pageControl's current page accordingly
    self.pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x / self.view.frame.size.width + 0.5);
}

#pragma mark - World At

- (Level *)objectAtWorld:(int)luid {
    return levelArray[luid-1];
}

@end
