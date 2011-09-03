//
//  ConverterVC.m
//  geoconverterhd
//
//  Created by zhang yang on 11-8-16.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "ConverterVC.h"
#import "RootVC.h"

@implementation ConverterVC

@synthesize rootVC;
@synthesize LatitudeSW;
@synthesize LongitudeSW;
@synthesize latDe;
@synthesize latMin;
@synthesize latSec;
@synthesize longDe;
@synthesize longMin;
@synthesize longSec;
@synthesize geoButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self numToDegree];
//    // one tap to dismiss keyboard 
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResp:)];
//    tap.numberOfTapsRequired=1;
//    [self.view addGestureRecognizer:tap];
//    [tap release];
}


-(IBAction)resignFirstResp:(UIGestureRecognizer*)gestureRecognizer{
    if([latDe isFirstResponder]){
        [latDe resignFirstResponder];
    }else if([latMin isFirstResponder]){
        [latMin resignFirstResponder];
    }else if([latSec isFirstResponder]){
        [latSec resignFirstResponder];
    }else if([longDe isFirstResponder]){
        [longDe resignFirstResponder];
    }else if([longMin isFirstResponder]){
        [longMin resignFirstResponder];
    }else if([longSec isFirstResponder]){
        [longSec resignFirstResponder];
    }
}

- (IBAction)converter:(id)sender {
    [self degreeToNum];
    [rootVC geoButtonClick];
    [rootVC dismissModal:nil];
}

- (IBAction)cancelClick:(id)sender {
    [rootVC dismissModal:nil];
}

-(void) degreeToNum{
    float latDeInput = fabsf(roundf([latDe.text floatValue]* 1000000.));
    float latMinInput = fabsf(roundf([latMin.text floatValue]* 1000000.));
    float latSecInput = fabsf(roundf([latSec.text floatValue]* 1000000.));
    float longDeInput = fabsf(roundf([longDe.text floatValue]* 1000000.));
    float longMinInput = fabsf(roundf([longMin.text floatValue]* 1000000.));
    float longSecInput = fabsf(roundf([longSec.text floatValue]* 1000000.));
    
    float latiInput = roundf(latDeInput + (latMinInput/60.) + (latSecInput/3600.) )/1000000;
    if (LatitudeSW.selectedSegmentIndex == 1) {
        latiInput = latiInput *-1;
    }
    float longiInput = roundf(longDeInput + (longMinInput/60.) + (longSecInput/3600.) )/1000000;
    if (LongitudeSW.selectedSegmentIndex == 1) {
        longiInput = longiInput *-1;
    }
    rootVC.latitude.text = [NSString stringWithFormat:@"%f",latiInput];
    rootVC.longitude.text = [NSString stringWithFormat:@"%f",longiInput];
}

-(void) numToDegree{
    float latiInput = [rootVC.latitude.text floatValue];
    if (latiInput >= 0) {
        LatitudeSW.selectedSegmentIndex = 0;
    }else{
        LatitudeSW.selectedSegmentIndex = 1;
        latiInput = latiInput*-1;
    }
    float latAbs = roundf(latiInput * 1000000.);
    
    latDe.text = [ NSString stringWithFormat:@"%d", (int)floorf(latAbs / 1000000)];
    latMin.text = [ NSString stringWithFormat:@"%d", (int)roundf((floorf(( (latAbs/1000000) - floorf(latAbs/1000000) ) * 60)) )];
    latSec.text = [ NSString stringWithFormat:@"%d", (int)roundf((( floorf(((((latAbs/1000000) - floorf(latAbs/1000000)) * 60) - floorf(((latAbs/1000000) - floorf(latAbs/1000000)) * 60)) * 100000) *60/100000 ) ))];
    
    float longiInput = [rootVC.longitude.text floatValue];
    if (longiInput >= 0) {
        LongitudeSW.selectedSegmentIndex = 0;
    }else{
        LongitudeSW.selectedSegmentIndex = 1;
        longiInput = longiInput*-1;
    }
    
    float lonAbs = roundf(longiInput * 1000000.);
    
    longDe.text = [ NSString stringWithFormat:@"%d", (int)floorf(lonAbs / 1000000) ];
    longMin.text = [ NSString stringWithFormat:@"%d", (int)(floorf(((lonAbs/1000000) - floorf(lonAbs/1000000)) * 60)) ];
    longSec.text = [ NSString stringWithFormat:@"%d", (int)(( floorf(((((lonAbs/1000000) - floorf(lonAbs/1000000)) * 60) - floorf(((lonAbs/1000000) - floorf(lonAbs/1000000)) * 60)) * 100000) *60/100000 )) ];
}


- (void)viewDidUnload
{
    [self setLatitudeSW:nil];
    [self setLongitudeSW:nil];
    [self setLatDe:nil];
    [self setLatMin:nil];
    [self setLatSec:nil];
    [self setLongDe:nil];
    [self setLongMin:nil];
    [self setLongSec:nil];
    [self setGeoButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
//    CLogc;
    [LatitudeSW release];
    [LongitudeSW release];
    [latDe release];
    [latMin release];
    [latSec release];
    [longDe release];
    [longMin release];
    [longSec release];
    [geoButton release];
    [super dealloc];
}
@end
