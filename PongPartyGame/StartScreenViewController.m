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

-(CGSize)viewSize
{
    CGSize size;
    if ([UIScreen mainScreen] == m_screen)
        size = CGSizeMake( self.view.bounds.size.height, self.view.bounds.size.width);
    else
        size = self.view.bounds.size;
    return size;
}


-(void)loadView
{    
    self.view = [[UIView alloc] initWithFrame: [m_screen bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGSize viewSize = [self viewSize];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    BOOL isIPad = [deviceType hasPrefix:@"iPad"];
    
    CGFloat verticalMargin = isIPad ? 50 : 20;
    CGFloat logoFontSize = isIPad ? 100 : 50;
    buttonFontSize = isIPad ? 50 : 25;
    
    verticalPos = verticalMargin;
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
    
    
    m_startMultiplayerButton = [self buttonWithString:@"Multiplayer Game" andFont:buttonFont];
    m_startMultiplayerButton.center = CGPointMake(viewSize.width/2, verticalPos + m_startMultiplayerButton.bounds.size.height/2);
    [m_startMultiplayerButton addTarget:self action:@selector(onStartMultiplayer:) forControlEvents:UIControlEventTouchUpInside];
    m_startMultiplayerButton.hidden = YES;
    
    if ([[GKLocalPlayer localPlayer] isAuthenticated]) {
        [self addMultiplayerButton];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGKLocalPlayerAuthenticated:)
                                                 name:@"GKLocalPlayerAuthenticated"
                                               object:nil];

}

- (void)onGKLocalPlayerAuthenticated:(NSNotification *)notification {
    [self addMultiplayerButton];
}

-(void)addMultiplayerButton
{
    if (m_startMultiplayerButton != nil) {
        m_startMultiplayerButton.hidden = NO;
    }
}


-(void)onStartGame:(id)sender
{
    [self startPongGameWithMode:LocalMultiplayer];
}

-(void)onStartMultiplayer:(id)sender
{
    NSLog(@"start multiplayer");

    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    
    [self presentModalViewController:mmvc animated:YES];    
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

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    // implement any specific code in your application here.
}
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
    // Display the error to the user.
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)matchmakerController didFindMatch:(GKMatch *)match
{
    NSLog(@"matchmakerViewController:didFindMatch %@ %d", match, match.expectedPlayerCount);
    [self dismissModalViewControllerAnimated:YES];
    PongGameViewController* viewController = [[PongGameViewController alloc] initWithMatch:match andScreen:m_screen];
    if (self.connectedController != nil) {
        viewController.connectedController = [self.connectedController startPongGameWithMode:SecondaryDisplay];
    }
    UINavigationController* navigationController = (UINavigationController*)self.parentViewController;
    [navigationController pushViewController:viewController animated:YES];
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
