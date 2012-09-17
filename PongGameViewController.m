//
//  PongGameViewController.m
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import "PongGameViewController.h"

@interface PongGameViewController ()

@end

@implementation PongGameViewController

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
