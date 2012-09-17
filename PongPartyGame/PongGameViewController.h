//
//  PongGameViewController.h
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKVector2.h>

enum PongGameMode {
    LocalMultiplayer,
    SecondaryDisplay
};

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
    UIScreen* screen;
    enum PongGameMode gameMode;
    
    PongGameViewController* __weak connectedController;
}

@property (strong, nonatomic) UIImageView* m_ball;
@property (strong, nonatomic) UIView* m_paddleLeft;
@property (strong, nonatomic) UIView* m_paddleRight;
@property (strong, nonatomic) UILabel* m_scoreLeftLabel;
@property (strong, nonatomic) UILabel* m_scoreRightLabel;

@property (weak, nonatomic) PongGameViewController*  connectedController;

-(id)initWithMode:(enum PongGameMode)mode andScreen:(UIScreen*)screen;

@end
