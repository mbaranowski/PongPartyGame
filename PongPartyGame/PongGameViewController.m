//
//  PongGameViewController.m
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import "PongGameViewController.h"

enum PongPacketType
{
    RandomNumber,
    GameStart,
    PaddlePosition,
    BallPosition,
    ScoreEvent
};

typedef struct
{
    Byte type;
    uint32_t randomNumber;
} PongRandomNumberPacket;

typedef struct
{
    Byte type;
    Byte isHost;
} PongGameStartPacket;

typedef struct
{
    Byte type;
    CGFloat paddleYPos;
} PongPaddlePositionPacket;

typedef struct
{
    Byte type;
    CGFloat posX, posY;
    CGFloat velX, velY, speed;
} PongBallPositionPacket;

typedef struct
{
    Byte type;
    Byte score;
    Byte isHostScore;
} PongScoreEventPacket;

@interface PongGameViewController ()

@end

@implementation PongGameViewController
@synthesize connectedController;
@synthesize m_ball;
@synthesize m_paddleLeft;
@synthesize m_paddleRight;
@synthesize m_scoreLeftLabel;
@synthesize m_scoreRightLabel;
@synthesize match;


-(id)initWithMode:(enum PongGameMode)inMode andScreen:(UIScreen*)inScreen
{
    if (self = [super init])
    {
        gameMode = inMode;
        screen = inScreen;
        self.match = nil;
    }
    return self;
}

-(id)initWithMatch:(GKMatch*)inMatch andScreen:(UIScreen*)inScreen
{
    if (self = [super init])
    {
        gameMode = NetworkMultiplayer;
        screen = inScreen;
        self.match = inMatch;
        self.match.delegate = self;
    }
    return self;
}

-(UIImage*)ballImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // use CGContext commands to draw stuff, ex. draw a circle
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillEllipseInRect(context, CGRectMake(0,0,size.width,size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage*)centerLineWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // use CGContext commands to draw stuff, ex. draw a circle
    //CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    //CGContextFillEllipseInRect(context, CGRectMake(0,0,size.width,size.height));
    CGContextSetRGBStrokeColor(context, 0.5f, 0.5f, 0.5f, 1.0f);
    CGContextSetLineWidth(context,  size.width);
    CGFloat dashLengths[] = { 15.0f, 15.0f };
    CGContextSetLineDash(context, 0, dashLengths, 2);
    
    CGContextMoveToPoint(context, size.width/2, 0);
    CGContextAddLineToPoint(context, size.width/2, size.height);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UILabel*)scoreLabelWithFont:(UIFont*)font
{
    CGSize size = [@"88" sizeWithFont:font];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = font;
    label.text = @"0";
    [self.view addSubview:label];
    return label;
}

-(UIButton*)buttonWithTitle:(NSString*)title andFont:(UIFont*)font
{
    CGSize size = [title sizeWithFont:font];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width+20, size.height+18)];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor darkGrayColor];
    button.titleLabel.font = font;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [self.view addSubview:button];
    return button;
}

-(void)setAndResizeLabel:(UILabel*)label withText:(NSString*)text
{
    CGSize size = [text sizeWithFont:label.font];
    CGPoint center = label.center;
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, size.width, size.height);
    label.text = text;
    label.center = center;
    label.hidden = NO;
}

-(void)loadView
{
    
    matchStarted = NO;

    self.view = [[UIView alloc] initWithFrame:[screen bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    
    //CGSize viewSize = self.view.bounds.size;
    CGSize viewSize;
    if ([UIScreen mainScreen] == screen)
        viewSize = CGSizeMake( self.view.bounds.size.height, self.view.bounds.size.width);
    else
        viewSize = self.view.bounds.size;

    NSString *deviceType = [UIDevice currentDevice].model;
    BOOL isIPad = [deviceType hasPrefix:@"iPad"];
    
    // TODO: the game field size needs to be scaled properly between iPhone and iPad
    // to enable fair multiplayer matches.
    CGSize paddleSize = CGSizeMake(20,120);
    CGFloat paddleMargin = isIPad ? 50 : 20;
    CGFloat scoreFontSize = isIPad ? 200 : 100;
    CGSize scoreMargin = isIPad ? CGSizeMake(50, 50) : CGSizeMake(20, 20);
    CGFloat playerNameFontSize = isIPad ? 30 : 15;
    
    m_paddleLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddleSize.width, paddleSize.height)];
    m_paddleLeft.center = CGPointMake(paddleMargin, viewSize.height/2);
    m_paddleLeft.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_paddleLeft];
    lastLeftPaddlePos = m_paddleLeft.center.y;
     
    m_paddleRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddleSize.width, paddleSize.height)];
    m_paddleRight.center = CGPointMake(viewSize.width-paddleMargin, viewSize.height/2);
    m_paddleRight.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_paddleRight];
    
    m_centerLine = [[UIImageView alloc] initWithImage:[self centerLineWithSize:CGSizeMake(10, viewSize.height)]];
    m_centerLine.center = CGPointMake(viewSize.width/2, viewSize.height/2);
    [self.view addSubview:m_centerLine];
    
    UIFont* scoreFont = [UIFont fontWithName:@"Futura-Medium" size:scoreFontSize];
    m_scoreLeftLabel = [self scoreLabelWithFont:scoreFont];
    m_scoreLeftLabel.center = CGPointMake(
        m_scoreLeftLabel.bounds.size.width/2 + scoreMargin.width,
        m_scoreLeftLabel.bounds.size.height/2 + scoreMargin.height);

    m_scoreRightLabel = [self scoreLabelWithFont:scoreFont];
    m_scoreRightLabel.center = CGPointMake(
        viewSize.width - m_scoreRightLabel.bounds.size.width/2 - scoreMargin.width,
        m_scoreRightLabel.bounds.size.height/2 + scoreMargin.height);
    
    UIFont* playerNameFont = [UIFont fontWithName:@"Futura-Medium" size:playerNameFontSize];
    m_leftPlayerNameLabel = [self scoreLabelWithFont:playerNameFont];
    m_leftPlayerNameLabel.center = CGPointMake( CGRectGetMidX(m_scoreLeftLabel.frame), 30 );
    m_leftPlayerNameLabel.hidden = YES;
    
    m_rightPlayerNameLabel = [self scoreLabelWithFont:playerNameFont];
    m_rightPlayerNameLabel.center = CGPointMake( CGRectGetMidX(m_scoreRightLabel.frame), 30 );
    m_rightPlayerNameLabel.hidden = YES;

    m_ball = [[UIImageView alloc] initWithImage:[self ballImageWithSize:CGSizeMake(24, 24)]];
    m_ball.center = CGPointMake(viewSize.width/2, viewSize.height/2);
    m_ball.backgroundColor = [UIColor clearColor];
    m_ball.hidden = YES;
    [self.view addSubview:m_ball];
    
    // quit game button on bottom of game board
    UIFont* smallButtonFont = [UIFont fontWithName:@"Futura-Medium" size:20];
    m_quitGameButton = [self buttonWithTitle:@"Main Menu" andFont:smallButtonFont];
    m_quitGameButton.center = CGPointMake(viewSize.width/2, viewSize.height - m_quitGameButton.bounds.size.height - 20);
    [m_quitGameButton addTarget:self action:@selector(onQuitGame:) forControlEvents:UIControlEventTouchUpInside];
    
    m_startGameButton = [self buttonWithTitle:@"Start Game" andFont:smallButtonFont];
    m_startGameButton.center = CGPointMake(viewSize.width/2, viewSize.height/2);
    [m_startGameButton addTarget:self action:@selector(onStartNetworkGame:) forControlEvents:UIControlEventTouchUpInside];
    m_startGameButton.hidden = YES;
    
    
    if (gameMode == LocalMultiplayer)
    {
        [self addGestureControlsToPaddle:m_paddleLeft];
        [self addGestureControlsToPaddle:m_paddleRight];
        [self initGame];
        [self startGameRound];
    }
    
    else if (gameMode == NetworkMultiplayer)
    {
        m_paddleRight.backgroundColor = [UIColor grayColor];
        randomNumber = arc4random();
        if (!matchStarted && match.expectedPlayerCount == 0)
        {
            [self beginGameHandshake];
        }

    }
}

-(void)startGameRound
{
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(initNewRound:) userInfo:nil repeats:NO];
}

-(void)addGestureControlsToPaddle:(UIView*)paddle
{
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    [paddle addGestureRecognizer:pan];
}

-(void)initGame
{
    frameRate = 1.0f / 60.0f;
    startVelocity = 5.0f;
    startDirection = GLKVector2Normalize( GLKVector2Make(4, 4) );
    ballVelocity = startVelocity - 0.5f;
    numBalls = 0;
}

-(void)onQuitGame:(id)sender
{
    UINavigationController* navigationController = (UINavigationController*)self.parentViewController;
    [navigationController popViewControllerAnimated:YES];
}

-(void)initNewRound:(NSTimer*)timer
{
    m_ball.hidden = NO;
    if (self.connectedController) self.connectedController.m_ball.hidden = NO;

    m_ball.center = CGPointMake( CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) );
    
    numBalls += 1;
    if ((numBalls % 3) == 0)
        startDirection.y = -startDirection.y;
    
    startDirection.x = -startDirection.x;
    ballDirection = startDirection;
    ballVelocity = startVelocity;
    
    NSLog(@"starting update");
    if (![updateTimer isValid])
    {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:frameRate
                                         target:self
                                       selector:@selector(update:)
                                       userInfo:nil
                                        repeats:YES];
    }
    
    if (gameMode == NetworkMultiplayer)
    {
        if (isPlayerLeft) {
            [self sendBallPosition];
        }
        NSLog(@"starting network update");
        CGFloat networkRate = 1.0f / 20.0f;
        if (![networkTimer isValid]) {
            networkTimer = [NSTimer scheduledTimerWithTimeInterval:networkRate
                                                            target:self
                                                          selector:@selector(networkUpdate:) userInfo:nil repeats:YES];
        }
    }
}

-(void)panGesture:(UIPanGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Pan gesture dragging");
        CGPoint panDelta = [sender translationInView: self.view];
        CGFloat y = sender.view.center.y + panDelta.y;
        
        CGFloat yMin = sender.view.bounds.size.height/2;
        CGFloat yMax = self.view.bounds.size.height - yMin;
        if (y < yMin) y = yMin;
        if (y > yMax) y = yMax;
        
        sender.view.center = CGPointMake( sender.view.center.x, y );
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

-(void)onHitWithPaddleRect:(CGRect)paddleRect direction:(CGFloat)dir y:(CGFloat)newPosY
{
    CGFloat y = (newPosY - CGRectGetMidY(paddleRect)) / (paddleRect.size.height + m_ball.bounds.size.height) * 2.0f;
    CGFloat boundsAngle = y * ((70.0f * M_PI) / 180.0f);
    ballDirection.x = cosf(boundsAngle) * dir;
    ballDirection.y = sinf(boundsAngle);
    ballVelocity += 0.5f;
}

-(void)update:(NSTimer*)timer
{
    GLKVector2 pos = GLKVector2Make(m_ball.center.x, m_ball.center.y);
    GLKVector2 newPos = GLKVector2Add(pos, GLKVector2MultiplyScalar(ballDirection, ballVelocity));
    m_ball.center = CGPointMake(newPos.x, newPos.y);
    
    CGSize ballSize = m_ball.bounds.size;
    CGSize ballHalfSize = CGSizeMake(ballSize.width/2, ballSize.height/2);
    CGSize gameBounds = self.view.bounds.size;
    
    if (gameMode != NetworkMultiplayer || isPlayerLeft)
    {
        BOOL directionChanged = NO;

        if (ballDirection.x < 0)
        {
            CGRect paddleRect = m_paddleLeft.frame;
            CGFloat paddleEdge = paddleRect.origin.x + paddleRect.size.width + ballHalfSize.width;
            
            if (    newPos.y > (paddleRect.origin.y - ballHalfSize.height)
                &&  newPos.y < (paddleRect.origin.y + paddleRect.size.height + ballHalfSize.height)
                &&  newPos.x < (paddleEdge)
                &&  newPos.x > (paddleEdge - paddleRect.size.width))
            {
                [self onHitWithPaddleRect:paddleRect direction:1.0f  y:newPos.y];
                newPos.x = paddleEdge;
                directionChanged = YES;
            }
        }
        if (ballDirection.x > 0)
        {
            CGRect paddleRect = m_paddleRight.frame;
            CGFloat paddleEdge = paddleRect.origin.x - ballHalfSize.width;
            
            if (    newPos.y > (paddleRect.origin.y - ballHalfSize.height)
                &&  newPos.y < (paddleRect.origin.y + paddleRect.size.height + ballHalfSize.height)
                &&  newPos.x > (paddleEdge)
                &&  newPos.x < (paddleEdge + paddleRect.size.width))
            {
                [self onHitWithPaddleRect:paddleRect direction:-1.0f y:newPos.y];
                newPos.x = paddleEdge;
                directionChanged = YES;
            }
        }
        
        if (newPos.y < ballHalfSize.height) {
            newPos.y = ballHalfSize.height;
            ballDirection.y = -ballDirection.y;
            directionChanged = YES;
        } else if (newPos.y > (gameBounds.height - ballHalfSize.height)) {
            newPos.y = (gameBounds.height - ballHalfSize.height);
            ballDirection.y = -ballDirection.y;
            directionChanged = YES;
        }
        
        if (directionChanged && isPlayerLeft) {
            [self sendBallPosition];
        }
    
        BOOL resetGame = NO;
        if (newPos.x < -ballHalfSize.width) {
            m_scoreRight += 1;
            m_scoreRightLabel.text = [NSString stringWithFormat:@"%d", m_scoreRight];
            if (self.connectedController != nil) {
                self.connectedController.m_scoreRightLabel.text = m_scoreRightLabel.text;
            }
            if (isPlayerLeft) {
                [self sendScoreEvent:NO];
            }
            resetGame = YES;
        }
        
        if (newPos.x > gameBounds.width + ballHalfSize.width) {
            m_scoreLeft += 1;
            m_scoreLeftLabel.text = [NSString stringWithFormat:@"%d", m_scoreLeft];
            if (self.connectedController != nil) {
                self.connectedController.m_scoreLeftLabel.text = m_scoreLeftLabel.text;
            }
            if (isPlayerLeft) {
                [self sendScoreEvent:YES];
            }
            resetGame = YES;
        }

        if (resetGame) {
            [updateTimer invalidate];
            updateTimer = nil;
            [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(initNewRound:) userInfo:nil repeats:NO];
        }
    
    }
    
    if (self.connectedController != nil) {
        self.connectedController.m_ball.center = m_ball.center;
        self.connectedController.m_paddleLeft.center = m_paddleLeft.center;
        self.connectedController.m_paddleRight.center = m_paddleRight.center;
    }
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

//
// Network Multiplayer support
//

-(void)startNetworkMatch
{
    NSLog(@"startNetworkMatch");
    matchStarted = YES;
    
    [self addGestureControlsToPaddle:m_paddleLeft];
    [self initGame];
    [self startGameRound]; // starts networkUpdate among other things
}

-(void)networkUpdate:(NSTimer*)timer
{
    if (m_paddleLeft.center.y != lastLeftPaddlePos)
    {
        lastLeftPaddlePos = m_paddleLeft.center.y;
        [self sendPaddlePacketWithY: lastLeftPaddlePos];
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    const Byte* bytes = [data bytes];
    enum PongPacketType type = (enum PongPacketType)bytes[0];
    
    switch (type)
    {
        case RandomNumber:
        {
            NSLog(@"Recvd RandomNumber");
            const PongRandomNumberPacket* msg = (PongRandomNumberPacket*)bytes;
            
            receivedRandomNumber = YES;
            if (randomNumber > msg->randomNumber) {
                isPlayerLeft = YES;
                [self tryToEnableGame];
            }
            else if (randomNumber < msg->randomNumber) {
                isPlayerLeft = NO;
            }
            else {
                randomNumber = arc4random();
                receivedRandomNumber = NO;
                [self sendRandomNumberPacket];
            }
            
            NSLog(@"Received Random Number %d player %@", msg->randomNumber, isPlayerLeft ? @"Left" : @"Right");

        } break;

        case PaddlePosition:
        {
            const PongPaddlePositionPacket* msg = (PongPaddlePositionPacket*)bytes;
            m_paddleRight.center = CGPointMake(m_paddleRight.center.x, msg->paddleYPos);
            //NSLog(@"PaddlePosition recvd %f", msg->paddleYPos);
        } break;
            
        case BallPosition:
        {

            const PongBallPositionPacket* msg = (const PongBallPositionPacket*)bytes;
            m_ball.center = CGPointMake( msg->posX, msg->posY);
            ballDirection = GLKVector2Make( msg->velX, msg->velY);
            ballVelocity = msg->speed;
            
            //NSLog(@"recv BallPosition px:%f py:%f vx:%f vy:%f s:%f",
            //     msg->posX, msg->posY, msg->velX, msg->velY, msg->speed);

        } break;
            
        case GameStart:
        {
            NSLog(@"recvd GameStart");
            [self startNetworkMatch];
        } break;
            
        case ScoreEvent:
        {
            const PongScoreEventPacket* msg = (const PongScoreEventPacket*)bytes;
            if (msg->isHostScore) {
                m_scoreRightLabel.text = [NSString stringWithFormat:@"%d", msg->score];
            } else {
                m_scoreLeftLabel.text = [NSString stringWithFormat:@"%d", msg->score];
            }
        } break;
    };
    
    if (type == PaddlePosition) {

    }
}

-(void)sendRandomNumberPacket
{
    NSLog(@"sendRandomNumberPacket %d", randomNumber);

    PongRandomNumberPacket msg;
    msg.type = RandomNumber;
    msg.randomNumber = randomNumber;
    NSData *data = [NSData dataWithBytes:&msg length:sizeof(PongRandomNumberPacket)];
    [self broadcastData:data withDataMode:GKMatchSendDataReliable];
}


-(void)sendGameStartPacket
{
    if (isPlayerLeft)
    {
        NSLog(@"send GameStart");
        PongGameStartPacket msg;
        msg.type = GameStart;
        msg.isHost = isPlayerLeft ? 1 : 0;
        NSData *data = [NSData dataWithBytes:&msg length:sizeof(PongGameStartPacket)];
        [self broadcastData:data withDataMode:GKMatchSendDataReliable];
    } else {
        NSLog(@"Error, only left player can send start game packet!");
    }
}

-(void)sendPaddlePacketWithY:(CGFloat)y
{
    //NSLog(@"sendPaddlePacketWithY %f", y);
    PongPaddlePositionPacket msg;
    msg.type = PaddlePosition;
    msg.paddleYPos = m_paddleLeft.center.y;
    NSData *data = [NSData dataWithBytes:&msg length:sizeof(PongPaddlePositionPacket)];
    [self broadcastData:data withDataMode:GKMatchSendDataUnreliable];
}

-(void)sendBallPosition
{
    PongBallPositionPacket msg;
    msg.type = BallPosition;
    msg.posX = self.view.bounds.size.width - m_ball.center.x;
    msg.posY = m_ball.center.y;
    msg.velX = -ballDirection.x;
    msg.velY = ballDirection.y;
    msg.speed = ballVelocity;
    
    //NSLog(@"recv BallPosition px:%f py:%f vx:%f vy:%f s:%f",
    //      msg.posX, msg.posY, msg.velX, msg.velY, msg.speed);

    NSData *data = [NSData dataWithBytes:&msg length:sizeof(PongBallPositionPacket)];
    [self broadcastData:data withDataMode:GKMatchSendDataUnreliable];
}

-(void)sendScoreEvent:(BOOL)sendLeftScore
{
    PongScoreEventPacket msg;
    msg.type = ScoreEvent;
    msg.score = (sendLeftScore) ? m_scoreLeft : m_scoreRight;
    msg.isHostScore = sendLeftScore ? 1 : 0;
    NSData *data = [NSData dataWithBytes:&msg length:sizeof(PongBallPositionPacket)];
    [self broadcastData:data withDataMode:GKMatchSendDataUnreliable];
}

-(void)broadcastData:(NSData*)data withDataMode:(GKMatchSendDataMode)mode
{
    NSError* error;
    [self.match sendDataToAllPlayers:data withDataMode:mode error:&error];
    if (error != nil) {
        NSLog(@"Error in sendDataToAllPlayers %@", [error description]);
    }

}
- (void)match:(GKMatch *)thisMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    NSLog(@"GKMatch didChangeState %@ state %d", playerID, state);

    switch (state)
    {
        case GKPlayerStateConnected:
            NSLog(@"New Player Connected %@", playerID);
            break;
        case GKPlayerStateDisconnected:
            NSLog(@"Player Disconnected %@", playerID);
            break;
    }
    
    if (!matchStarted && thisMatch.expectedPlayerCount == 0)
    {
        [self beginGameHandshake];
    }
}

-(void)beginGameHandshake
{
    NSLog(@"beginGameHandshake");
    [self setAndResizeLabel:m_leftPlayerNameLabel withText:[[GKLocalPlayer localPlayer] alias]];
    
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error)
    {
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
        } else {

            GKPlayer* localPlayer = [GKLocalPlayer localPlayer];
        
            for (GKPlayer *player in players) {
                if ( ![player.playerID isEqualToString:localPlayer.playerID] ) {
                    [self setAndResizeLabel:m_rightPlayerNameLabel withText:[player alias]];

                }
            }
        }
    }];
    
    [self sendRandomNumberPacket];
    [self tryToEnableGame];
}

-(void)tryToEnableGame
{
    if (receivedRandomNumber && isPlayerLeft) {
        NSLog(@"show start button");
        m_startGameButton.hidden = NO;
    }
}

-(void)onStartNetworkGame:(id)sender
{
    m_startGameButton.hidden = YES;
    [self sendGameStartPacket];
    [self startNetworkMatch];
}

- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error
{
    NSLog(@"GKMatch connectionWithPlayerFailed %@", [error description]);
}

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error
{
    NSLog(@"GKMatch didFailWithError %@", [error description]);
}

- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID
{
    return NO;
}


@end
