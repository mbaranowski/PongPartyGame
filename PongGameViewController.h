//
//  PongGameViewController.h
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PongGameViewController : UIViewController
{
    UIImageView* m_ball;
    UIView* m_paddleLeft;
    UIView* m_paddleRight;
    UILabel* m_scoreLeftLeft;
    UILabel* m_scoreRightLeft;
    
    UIImageView* m_centerLine;
    
    int m_scoreLeft;
    int m_scoreRight;
    
    GLKVector2 ballDirection;
    CGFloat ballVelocity;
}


@end
