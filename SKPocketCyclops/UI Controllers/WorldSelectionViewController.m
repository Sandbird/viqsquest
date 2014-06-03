//
//  LevelSelectViewController.m
//  SKPocketCyclops
//
//  Created by Jacob Gundersen on 4/20/12.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "WorldSelectionViewController.h"
#import "LevelViewController.h"
#import "SKTAudio.h"

#import "PSKSharedTextureCache.h"

#import "WorldSelection.h"
#import "PSKGameManager.h"
#import "World.h"

@interface WorldSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@property (nonatomic, strong) NSArray *allWorlds;

@end

@implementation WorldSelectionViewController
@synthesize allWorlds;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // if any instances of WorldSelection exist, eliminate them
    for (UIView *view in self.scroller.subviews) {
        if ([view isKindOfClass:[WorldSelection class]]) {
            [view removeFromSuperview];
        }
    }
    
    // set the scroller's content size and also retrieve all the worlds
    CGFloat screenWidth = self.view.bounds.size.width;
    self.scroller.contentSize = CGSizeMake(screenWidth * 5, self.view.bounds.size.height);
    allWorlds = [[PSKGameManager sharedManager] retrieveAllWorlds];
    
    @autoreleasepool {
        CGRect r;
        // for each world in allworlds
        for (unsigned int i = 0; i < [allWorlds count]; i++) {
            // create an instance of worldselection
            World *w = allWorlds[i];
            WorldSelection *world = [[WorldSelection alloc] initWithFrame:CGRectMake(0, 0, 161, 161)];
            
            // set the instance's size and position
            r = world.frame;
            CGFloat x = (screenWidth - r.size.width) * 0.5 + screenWidth * i;
            r.origin.x = x;
            r.origin.y = (self.view.bounds.size.height - r.size.height) * 0.5;;
            world.frame = r;
            
            // set the world's name with font+color+auto adjustment size
            world.worldLabel.text = w.name;
            world.worldLabel.textAlignment = NSTextAlignmentCenter;
            [world.worldLabel setFont:[UIFont fontWithName:@"OldeEnglish-Regular" size:50]];
            [world.worldLabel setTextColor:[UIColor whiteColor]];
            [world.worldLabel setAdjustsFontSizeToFitWidth:YES];
            [world.worldLabel setMinimumScaleFactor:0.25];
            
            // load the corresponding world's image
            NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level_%d_icon",i+1] ofType:@"png"];
            NSData *data = [NSData dataWithContentsOfFile:file];
            UIImage *image = [UIImage imageWithData:data];
            
            // set the selection button's tag and image and target
            [world.selectionButton setTag:w.uid.integerValue];
            [world.selectionButton setImage:image forState:UIControlStateNormal];
            [world.selectionButton addTarget:self action:@selector(toLevelSelection:) forControlEvents:UIControlEventTouchUpInside];
            
            // if not unlocked, disable
            if (![w.isUnlocked boolValue]) {
                world.selectionButton.enabled = NO;
                world.alpha = 0.5;
            }
            
            // add as subview
            [self.scroller addSubview:world];
        }
    }

    // Enable pagination and set number of pages
    self.scroller.pagingEnabled = YES;
    [self.pageControl setNumberOfPages:[allWorlds count]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // update page control's current page accordingly
    self.pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x / self.view.frame.size.width + 0.5);
}

- (IBAction)backToMain:(id)sender {
    // pop to main menu
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)returnToWorldSelection:(UIStoryboardSegue *)segue {
    // set pageControl's current page correctly
    // set the uiscrollview's content offset correctly
    self.pageControl.currentPage = [[PSKGameManager sharedManager] worldUID] - 1;
    self.scroller.contentOffset = CGPointMake((self.pageControl.currentPage) * (self.view.frame.size.width), self.scroller.contentOffset.y);
    
    // play theme music
    [[SKTAudio sharedInstance] playBackgroundMusic:@"MFTheme.mp3"];
}

- (void)toLevelSelection:(UIButton *)sender {
    // if world 1, perform segue
    if (sender.tag == 1) {
        [self performSegueWithIdentifier:@"ToLevelSelect" sender:sender];
    } else {
        // show incomplete
        [[[UIAlertView alloc] initWithTitle:@"Unavailable" message:@"T'is a work in progres." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToLevelSelect"]) {
        // get the destinatino view controller
        // pass in the world UI
        LevelViewController *lvc = segue.destinationViewController;
        UIButton *button = (UIButton *)sender;
        [lvc setWorldUID:(int)button.tag];
        
        [[PSKGameManager sharedManager] setWorldUID:(int)button.tag];
    }
}

@end
