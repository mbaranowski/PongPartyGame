//
//  StartScreenViewController.h
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartScreenViewController : UIViewController
{
    UILabel* logoLabel;
    UIButton* m_startGameButton;
    UIScreen* m_screen;
    StartScreenViewController* __weak connectedController;
}

@property (strong, nonatomic) UILabel* logoLabel;
@property (strong, nonatomic) UIButton* m_startGameButton;
@property (weak, nonatomic) StartScreenViewController* connectedController;

-(id)initWithScreen:(UIScreen*)screen;

@end
