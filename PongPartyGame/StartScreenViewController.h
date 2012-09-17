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
    UILabel* m_logoLabel;
    UIButton* m_startGameButton;
}

@property (strong, nonatomic) UILabel* m_logoLabel;
@property (strong, nonatomic) UIButton* m_startGameButton;

@end
