//
//  StartScreenViewController.m
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import "StartScreenViewController.h"
#import "PongGameViewController.h"
#import <MediaPlayer/MPVolumeView.h>

@interface StartScreenViewController ()
@end

@implementation StartScreenViewController
@synthesize logoLabel;
@synthesize connectedController;

-(id)initWithScreen:(UIScreen*)inScreen;
{
    if (self = [super init]) {
        m_screen = inScreen;
    }
    
    return self;
}
-(UIButton*)buttonWithString:(NSString*)title andFont:(UIFont*)font
{
    CGSize size = [title sizeWithFont:font];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width+30, size.height+24)];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor darkGrayColor];
    button.titleLabel.font = font;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [self.view addSubview:button];
    return button;
    
}
-(void)loadView
{    
    self.view = [[UIView alloc] initWithFrame: [m_screen bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGSize viewSize;
    if ([UIScreen mainScreen] == m_screen)
        viewSize = CGSizeMake( self.view.bounds.size.height, self.view.bounds.size.width);
    else
        viewSize = self.view.bounds.size;
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    BOOL isIPad = [deviceType hasPrefix:@"iPad"];
    CGFloat verticalMargin = isIPad ? 50 : 20;
    CGFloat logoFontSize = isIPad ? 100 : 50;
    CGFloat buttonFontSize = isIPad ? 50 : 25;
    
    CGFloat verticalPos = verticalMargin;
    NSString* logoStr = @"PONG";
    UIFont* logoFont = [UIFont fontWithName:@"Futura-Medium" size:logoFontSize];
    CGSize logoSize = [logoStr sizeWithFont:logoFont];
    logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, logoSize.width, logoSize.height)];
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.font = logoFont;
    logoLabel.textAlignment = UITextAlignmentCenter;
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.center = CGPointMake(viewSize.width/2, verticalPos + logoSize.height/2);
    logoLabel.text = logoStr;
    [self.view addSubview:logoLabel];
    
    verticalPos += logoSize.height + verticalMargin;
    
    
    UIFont* buttonFont = [UIFont fontWithName:@"Futura-Medium" size:buttonFontSize];
    m_startGameButton = [self buttonWithString:@"Start Game" andFont:buttonFont];
    m_startGameButton.center = CGPointMake(viewSize.width/2, verticalPos + m_startGameButton.bounds.size.height/2);
    [m_startGameButton addTarget:self action:@selector(onStartGame:) forControlEvents:UIControlEventTouchUpInside];
    verticalPos += m_startGameButton.bounds.size.height + verticalMargin;
    
    /*
    MPVolumeView *volumeView = [ [MPVolumeView alloc] initWithFrame:CGRectMake(0,0,100,50)];
    [volumeView setShowsVolumeSlider:YES];
    //[volumeView sizeToFit];
    volumeView.backgroundColor = [UIColor grayColor];
    volumeView.center = CGPointMake(viewSize.width/2, verticalPos + 100);
    [self.view addSubview:volumeView];
     */
}

-(void)onStartGame:(id)sender
{
    [self startPongGameWithMode:LocalMultiplayer];
}

-(PongGameViewController*)startPongGameWithMode:(enum PongGameMode)mode
{
    PongGameViewController* viewController = [[PongGameViewController alloc] initWithMode:mode andScreen:m_screen];

    if (self.connectedController != nil) {
        viewController.connectedController = [self.connectedController startPongGameWithMode:SecondaryDisplay];
    }
    
    UINavigationController* navigationController = (UINavigationController*)self.parentViewController;
    [navigationController pushViewController:viewController animated:YES];
    return viewController;
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
    if ([UIScreen mainScreen] == m_screen)
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
                || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    else
        return NO;
    
}

@end
