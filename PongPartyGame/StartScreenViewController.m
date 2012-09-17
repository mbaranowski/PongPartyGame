//
//  StartScreenViewController.m
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import "StartScreenViewController.h"
#import "PongGameViewController.h"

@interface StartScreenViewController ()
@end

@implementation StartScreenViewController
@synthesize m_logoLabel;

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
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    CGSize viewSize = CGSizeMake( self.view.bounds.size.height, self.view.bounds.size.width);
    
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"device type %@", deviceType);
    
    
    BOOL isIPad = [deviceType hasPrefix:@"iPad"];
    CGFloat verticalMargin = isIPad ? 50 : 20;
    CGFloat logoFontSize = isIPad ? 100 : 50;
    CGFloat buttonFontSize = isIPad ? 50 : 25;
    
    
    
    CGFloat verticalPos = verticalMargin;
    NSString* logoStr = @"PONG";
    UIFont* logoFont = [UIFont fontWithName:@"Futura-Medium" size:logoFontSize];
    CGSize logoSize = [logoStr sizeWithFont:logoFont];
    m_logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, logoSize.width, logoSize.height)];
    m_logoLabel.backgroundColor = [UIColor clearColor];
    m_logoLabel.font = logoFont;
    m_logoLabel.textAlignment = UITextAlignmentCenter;
    m_logoLabel.textColor = [UIColor whiteColor];
    m_logoLabel.center = CGPointMake(viewSize.width/2, verticalPos + logoSize.height/2);
    m_logoLabel.text = logoStr;
    [self.view addSubview:m_logoLabel];
    
    verticalPos += logoSize.height + verticalMargin;
    
    
    UIFont* buttonFont = [UIFont fontWithName:@"Futura-Medium" size:buttonFontSize];
    m_startGameButton = [self buttonWithString:@"Start Game" andFont:buttonFont];
    m_startGameButton.center = CGPointMake(viewSize.width/2, verticalPos + m_startGameButton.bounds.size.height/2);
    [m_startGameButton addTarget:self action:@selector(onStartGame:) forControlEvents:UIControlEventTouchUpInside];
    verticalPos += m_startGameButton.bounds.size.height + verticalMargin;

}

-(void)onStartGame:(id)sender
{
    NSLog(@"onStartGame");
    PongGameViewController* viewController = [[PongGameViewController alloc] init];
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
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
