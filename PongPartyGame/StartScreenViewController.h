//
//  StartScreenViewController.h
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface StartScreenViewController : UIViewController <GKMatchmakerViewControllerDelegate>
{
    UILabel* logoLabel;
    UIButton* m_startGameButton;
    UIButton* m_startMultiplayerButton;
    UIScreen* m_screen;
    StartScreenViewController* __weak connectedController;
    CGFloat buttonFontSize;
    CGFloat verticalPos;
}

@property (strong, nonatomic) UILabel* logoLabel;
@property (strong, nonatomic) UIButton* m_startGameButton;
@property (strong, nonatomic) UIButton* m_startMultiplayerButton;

@property (weak, nonatomic) StartScreenViewController* connectedController;

-(id)initWithScreen:(UIScreen*)screen;

@end
