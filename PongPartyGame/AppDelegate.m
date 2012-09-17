//
//  AppDelegate.m
//  PongPartyGame
//
//  Created by Matthew Baranowski on 9/17/12.
//  Copyright (c) 2012 Matthew Baranowski. All rights reserved.
//

#import "AppDelegate.h"
#import "StartScreenViewController.h"
#import "PongGameViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.windows = [NSMutableArray arrayWithCapacity:2];
    NSArray* screens = [UIScreen screens];
    StartScreenViewController* mainStartScreen = nil;
    for (UIScreen* screen in screens)
    {
        BOOL isMainScreen = (screen == [UIScreen mainScreen]);
        UIWindow* window = [self createWindowForScreen:screen];
        
        StartScreenViewController* viewController = [[StartScreenViewController alloc] initWithScreen:screen];
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.navigationBarHidden = TRUE;
        
        [self addViewController:navController toWindow:window];
        
        if (isMainScreen) {
            [window makeKeyAndVisible];
            mainStartScreen = viewController;
        }
        else {
            mainStartScreen.connectedController = viewController;
        }
    }

    return YES;
}

-(UIWindow*)createWindowForScreen:(UIScreen*)screen
{
    UIWindow* w = nil;
    for (UIWindow* window in self.windows)
    {
        if (window.screen == screen) {
            w = window;
        }
    }
    
    if (w == nil) {
        w = [[UIWindow alloc] initWithFrame:screen.bounds];
        [w setScreen:screen];
        [self.windows addObject:w];
    }
    
    return w;
}

-(void)addViewController:(UIViewController*)controller toWindow:(UIWindow*)window
{
    [window setRootViewController:controller];
    window.hidden = NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
