//
//  PongGameViewController.h
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKVector2.h>
#import <GameKit/GameKit.h>

enum PongGameMode {
    LocalMultiplayer,
    SecondaryDisplay,
    NetworkMultiplayer
};

@interface PongGameViewController : UIViewController <UIGestureRecognizerDelegate, GKMatchDelegate>
{
    UIImageView* m_ball;
    UIView* m_paddleLeft;
    UIView* m_paddleRight;
    UILabel* m_scoreLeftLabel;
    UILabel* m_scoreRightLabel;
    UIButton* m_quitGameButton;
    
    UILabel* m_leftPlayerNameLabel;
    UILabel* m_rightPlayerNameLabel;
    UIButton* m_startGameButton;
    
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
    
    // network multiplayer support
    GKMatch* match;
    BOOL matchStarted;
    NSTimer* networkTimer;
    CGFloat lastLeftPaddlePos;
    uint32_t randomNumber;
    BOOL isPlayerLeft;
    BOOL receivedRandomNumber;
    
    
    PongGameViewController* __weak connectedController;
}

@property (strong, nonatomic) UIImageView* m_ball;
@property (strong, nonatomic) UIView* m_paddleLeft;
@property (strong, nonatomic) UIView* m_paddleRight;
@property (strong, nonatomic) UILabel* m_scoreLeftLabel;
@property (strong, nonatomic) UILabel* m_scoreRightLabel;
@property (strong, nonatomic) GKMatch* match;

@property (weak, nonatomic) PongGameViewController*  connectedController;

-(id)initWithMode:(enum PongGameMode)mode andScreen:(UIScreen*)screen;
-(id)initWithMatch:(GKMatch*)match andScreen:(UIScreen*)screen;

@end
