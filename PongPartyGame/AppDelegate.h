//
//  AppDelegate.h
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray* windows;
}

@property (strong, nonatomic) NSMutableArray* windows;
@property (strong, nonatomic) UIWindow *window;

@end
