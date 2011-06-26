//
//  geoconverterAppDelegate.h
//  geoconverter
//
//  Created by lich0079 on 11-6-26.
//  Copyright 2011年 ibm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface geoconverterAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
