//
//  geoconverterAppDelegate.m
//  geoconverter
//
//  Created by lich0079 on 11-6-26.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "geoconverterAppDelegate.h"

void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
}



@implementation geoconverterAppDelegate

@synthesize window=_window;

@synthesize rootVC;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
#ifndef DEBUG
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FlurryAnalytics setAppVersion:@"1.66"];
    [FlurryAnalytics startSession:@"GRXY6JSMUXWJIP711RAV"];
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
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
    
    if(![userDefault valueForKey:@"version1.30helpchecked"]){
        [userDefault setValue:@"YES" forKey:@"version1.30helpchecked"];
        [userDefault synchronize];
        [rootVC helpButtonClick:nil];
    }
    
    [rootVC stopLoading];
    
    if([userDefault objectForKey:@"drawlines"]){
        BOOL drawlines = [userDefault boolForKey:@"drawlines"];
        if (drawlines) {
            if (!rootVC.hasDrawLines) {
                [rootVC addLatitudeAndLongitudeOverLayView];
                rootVC.hasDrawLines = YES;
            }
        }else{
            [rootVC.map removeOverlays:rootVC.map.overlays];
            rootVC.hasDrawLines = NO;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
    [rootVC release];
    [_window release];
    [super dealloc];
}

@end
