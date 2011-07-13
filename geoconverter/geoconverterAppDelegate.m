//
//  geoconverterAppDelegate.m
//  geoconverter
//
//  Created by lich0079 on 11-6-26.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "geoconverterAppDelegate.h"

@implementation geoconverterAppDelegate

@synthesize window=_window;

@synthesize rootVC;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog(@"%s",__FUNCTION__);
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//    NSLog(@"%s",__FUNCTION__);
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    NSLog(@"%s",__FUNCTION__);
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    NSLog(@"%s",__FUNCTION__);
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    CLog(@"%s", __FUNCTION__);
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault synchronize];
    
    //avoid user never enter pref
    if([userDefault objectForKey:@"mapautozoom"]){
        rootVC.enableZoom = [userDefault boolForKey:@"mapautozoom"];
        rootVC.enableTap = [userDefault boolForKey:@"onetap"];
    }

    if(!rootVC.enableTap){
        if(rootVC.onetapGR){
            [rootVC.map removeGestureRecognizer:rootVC.onetapGR];
            rootVC.onetapGR = nil;
        }
    }else{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:rootVC action:@selector(tap:)];
        tap.numberOfTapsRequired=1;
        [rootVC.map addGestureRecognizer:tap];
        rootVC.onetapGR = tap;
        [tap release];
    }
    
    if(![userDefault valueForKey:@"version1.0helpchecked"]){
        [rootVC helpButtonClick:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    NSLog(@"%s",__FUNCTION__);
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
//    NSLog(@"%s",__FUNCTION__);
    [rootVC release];
    [_window release];
    [super dealloc];
}

@end
