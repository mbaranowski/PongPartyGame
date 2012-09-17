//
//  PongGameViewController.m
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import "PongGameViewController.h"

@interface PongGameViewController ()

@end

@implementation PongGameViewController

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

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGSize viewSize = self.view.bounds.size;
    
    CGSize paddleSize = CGSizeMake(20,120);
    CGFloat paddleMargin = 50;
    CGFloat scoreFontSize = 200;
    CGSize scoreMargin = CGSizeMake(50, 50);
    
    m_paddleLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddleSize.width, paddleSize.height)];
    m_paddleLeft.center = CGPointMake(paddleMargin, viewSize.width/2);
    m_paddleLeft.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_paddleLeft];
     
    m_paddleRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddleSize.width, paddleSize.height)];
    m_paddleRight.center = CGPointMake(viewSize.height-paddleMargin, viewSize.width/2);
    m_paddleRight.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_paddleRight];
    
    m_centerLine = [[UIImageView alloc] initWithImage:[self centerLineWithSize:CGSizeMake(10, viewSize.width)]];
    m_centerLine.center = CGPointMake(viewSize.height/2, viewSize.width/2);
    [self.view addSubview:m_centerLine];
    
    UIFont* scoreFont = [UIFont fontWithName:@"Futura-Medium" size:scoreFontSize];
    m_scoreLeftLabel = [self scoreLabelWithFont:scoreFont];
    m_scoreLeftLabel.center = CGPointMake(
        m_scoreLeftLabel.bounds.size.width/2 + scoreMargin.width,
        m_scoreLeftLabel.bounds.size.height/2 + scoreMargin.height);

    m_scoreRightLabel = [self scoreLabelWithFont:scoreFont];
    m_scoreRightLabel.center = CGPointMake(
        viewSize.height - m_scoreRightLabel.bounds.size.width/2 - scoreMargin.width,
        m_scoreRightLabel.bounds.size.height/2 + scoreMargin.height);
    
    m_ball = [[UIImageView alloc] initWithImage:[self ballImageWithSize:CGSizeMake(24, 24)]];
    m_ball.center = CGPointMake(viewSize.width/2, viewSize.height/2);
    m_ball.backgroundColor = [UIColor clearColor];
    m_ball.hidden = YES;
    [self.view addSubview:m_ball];
    
    UIPanGestureRecognizer* panLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panLeft.minimumNumberOfTouches = 1;
    panLeft.maximumNumberOfTouches = 1;
    [m_paddleLeft addGestureRecognizer:panLeft];
    
    UIPanGestureRecognizer* panRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panRight.minimumNumberOfTouches = 1;
    panRight.maximumNumberOfTouches = 1;
    [m_paddleRight addGestureRecognizer:panRight];
    
    frameRate = 1.0f / 60.0f;

    startVelocity = 5.0f;
    startDirection = GLKVector2Normalize( GLKVector2Make(4, 4) );
    ballVelocity = startVelocity - 0.5f;
    numBalls = 0;

    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(initGameState:) userInfo:nil repeats:NO];
}

-(void)initGameState:(NSTimer*)timer
{
    m_ball.hidden = NO;
    m_ball.center = CGPointMake( CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) );
    
    numBalls += 1;
    if ((numBalls % 3) == 0)
        startDirection.y = -startDirection.y;
    
    startDirection.x = -startDirection.x;
    ballDirection = startDirection;
    ballVelocity = startVelocity;
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:frameRate
                                     target:self
                                   selector:@selector(update:)
                                   userInfo:nil
                                    repeats:YES];
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
        }
    }
    
    if (newPos.y < ballHalfSize.height) {
        newPos.y = ballHalfSize.height;
        ballDirection.y = -ballDirection.y;
    } else if (newPos.y > (gameBounds.height - ballHalfSize.height)) {
        newPos.y = (gameBounds.height - ballHalfSize.height);
        ballDirection.y = -ballDirection.y;
    }
    
    BOOL resetGame = NO;
    if (newPos.x < -ballHalfSize.width) {
        m_scoreRight += 1;
        m_scoreRightLabel.text = [NSString stringWithFormat:@"%d", m_scoreRight];
        resetGame = YES;
    }
    
    if (newPos.x > gameBounds.width + ballHalfSize.width) {
        m_scoreLeft += 1;
        m_scoreLeftLabel.text = [NSString stringWithFormat:@"%d", m_scoreLeft];
        resetGame = YES;
    }

    if (resetGame) {
        [updateTimer invalidate];
        updateTimer = nil;
        
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(initGameState:) userInfo:nil repeats:NO];
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



@end
