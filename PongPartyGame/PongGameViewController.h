//
//  PongGameViewController.h
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKVector2.h>

@interface PongGameViewController : UIViewController <UIGestureRecognizerDelegate>
{
    UIImageView* m_ball;
    UIView* m_paddleLeft;
    UIView* m_paddleRight;
    UILabel* m_scoreLeftLabel;
    UILabel* m_scoreRightLabel;
    
    UIImageView* m_centerLine;
    
    int m_scoreLeft;
    int m_scoreRight;
    
    GLKVector2 ballDirection;
    GLKVector2 startDirection;
    CGFloat ballVelocity;
    CGFloat startVelocity;
    CGFloat frameRate;
    int numBalls;
    
    NSTimer* updateTimer;
}


@end
