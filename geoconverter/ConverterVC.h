//
//  ConverterVC.h
//  geoconverterhd
//
//  Created by zhang yang on 11-8-16.
//  Copyright 2011年 ibm. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootVC;

@interface ConverterVC : UIViewController {
    UISegmentedControl *LatitudeSW;
    UISegmentedControl *LongitudeSW;
    UITextField *latDe;
    UITextField *latMin;
    UITextField *latSec;
    UITextField *longDe;
    UITextField *longMin;
    UITextField *longSec;
    UIButton *geoButton;
    UIButton *cancelClick;
}


@property (assign, nonatomic) RootVC *rootVC;
@property (nonatomic, retain) IBOutlet UISegmentedControl *LatitudeSW;
@property (nonatomic, retain) IBOutlet UISegmentedControl *LongitudeSW;
@property (nonatomic, retain) IBOutlet UITextField *latDe;
@property (nonatomic, retain) IBOutlet UITextField *latMin;
@property (nonatomic, retain) IBOutlet UITextField *latSec;
@property (nonatomic, retain) IBOutlet UITextField *longDe;
@property (nonatomic, retain) IBOutlet UITextField *longMin;
@property (nonatomic, retain) IBOutlet UITextField *longSec;
@property (nonatomic, retain) IBOutlet UIButton *geoButton;


- (IBAction)converter:(id)sender;
- (IBAction)cancelClick:(id)sender;

-(void) degreeToNum;
-(void) numToDegree;
-(void) resignFirstResp:(UIGestureRecognizer*)gestureRecognizer;
@end
