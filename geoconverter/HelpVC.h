//
//  HelpVC.h
//  geoconverter
//
//  Created by lich0079 on 11-6-29.
//  Copyright 2011年 ibm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HelpVC;

@protocol HelpVCDelegate 

- (void)dismissModal:(HelpVC *)helpVC;

@end



@interface HelpVC : UIViewController {
    
}

@property (nonatomic, assign)  id<HelpVCDelegate> delegate;
@property (nonatomic, retain)  IBOutlet UIWebView  *web;

- (IBAction) closeClick:(id)sender;

@end




