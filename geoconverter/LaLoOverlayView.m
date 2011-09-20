//
//  LaLoOverlayView.m
//  geoconverterhd
//
//  Created by zhang yang on 11-8-8.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "LaLoOverlayView.h"

@implementation LaLoOverlayView

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)generateText {
  CLLocationCoordinate2D coordinate = [self.overlay coordinate];
    float lat = coordinate.latitude;
    float longi = coordinate.longitude;
    NSString *latString;
    if (lat >= 0 ) {
        latString = [NSString stringWithFormat:@"%@%d",N, (int)lat];
    }else{
        latString = [NSString stringWithFormat:@"%@%d",S, (int)lat*-1];
    }
    NSString *longString;
    if (longi >= 0 ) {
        longString = [NSString stringWithFormat:@"%@%d",E, (int)longi];
    }else{
        longString = [NSString stringWithFormat:@"%@%d",W, (int)longi*-1];
    }
    
    NSString *text = [NSString stringWithFormat:@"%@,%@",latString, longString];
  return text;
}
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context{
//    float zoom = 0.000004/zoomScale;
    MKMapRect  theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextSetAlpha(context, 0.5);
    
    float w, h;
    w = theRect.size.width;
    h = theRect.size.height;
    NSString *text = [self generateText];
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    char *commentsMsg;
    commentsMsg = (char *)[text UTF8String];
    CGContextSelectFont(context, "Helvetica-Bold", h, kCGEncodingMacRoman);// the h is the height of the text, it's key, because if it's small you can't see
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGAffineTransform myTextTransform =CGAffineTransformScale(CGAffineTransformIdentity, 1.f, -1.f );
    CGContextSetTextMatrix (context, myTextTransform);
    CGPoint xx = [self pointForMapPoint:theMapRect.origin];
    CGContextShowTextAtPoint(context,xx.x,xx.y,commentsMsg, strlen(commentsMsg));// the point must convert from mappoint to cgpoint
}

@end
