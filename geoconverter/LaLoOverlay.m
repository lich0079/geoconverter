//
//  LaLoOverlay.m
//  geoconverterhd
//
//  Created by zhang yang on 11-8-8.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "LaLoOverlay.h"

@implementation LaLoOverlay

@synthesize coordinate;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (CLLocationCoordinate2D)coordinate {
    return coordinate;                       
}

- (MKMapRect)boundingMapRect
{
    MKMapPoint upperLeft = MKMapPointForCoordinate(coordinate);
    
    CLLocationCoordinate2D lowerRightCoord = 
    CLLocationCoordinate2DMake(coordinate.latitude - 0.5,
                               coordinate.longitude + 0.5);
    
    MKMapPoint lowerRight = MKMapPointForCoordinate(lowerRightCoord);
    
    double width = lowerRight.x - upperLeft.x;
    double height = lowerRight.y - upperLeft.y;
    
    MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, width, height);
    return bounds;
}

@end
