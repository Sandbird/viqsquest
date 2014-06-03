//
//  AboutViewController.m
//  SKPocketCyclops
//
//  Created by Jacob Gundersen on 4/20/12.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "AboutViewController.h"
#import "SKTAudio.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    // Custom initialization
    }
    return self;
}

- (IBAction)backToMain:(id)sender {
    // return to main
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    // set font
    [textView setFont:[UIFont fontWithName:@"OldeEnglish-Regular" size:24]];
    
    // set creator
    [self appendText:@"Victarion's Quest"];
    [self appendText:@"Game developed by William"];
    
    // insert space
    [self appendText:@""];
    [self appendText:@""];
    [self appendText:@""];
    
    // credits
    [self appendText:@"Thank you to Mark Fowler for the background musics (piano)"];
    [self appendText:@"Thank you to raywenderlich for the various tutorials!"];
}

- (void)appendText:(NSString *)text {
    // get existing text, add \n and the passed in text
    // set the next string to textView
    NSString *existing = textView.text;
    existing = [NSString stringWithFormat:@"%@\n%@",existing,text];
    [textView setText:existing];
}

@end
