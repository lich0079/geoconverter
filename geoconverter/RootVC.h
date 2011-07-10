//
//  RootVC.h
//  geoconverter
//
//  Created by lich0079 on 11-6-27.
//  Copyright 2011年 ibm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h> 
#import "GTMHTTPFetcher.h"
#import "SBJsonParser.h"
#import "HelpVC.h"
#import <iAd/iAd.h>


@interface RootVC : UIViewController  <UITextFieldDelegate,MKReverseGeocoderDelegate,MKMapViewDelegate,UISearchBarDelegate,HelpVCDelegate,ADBannerViewDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIButton *geo;

@property (nonatomic, retain) IBOutlet UITextField *latitude;

@property (nonatomic, retain) IBOutlet UITextField *longitude;

@property (nonatomic, retain) IBOutlet MKMapView *map;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@property(nonatomic, retain) IBOutlet ADBannerView *banner;

@property BOOL enableZoom;

@property BOOL enableTap;

@property (nonatomic, assign) UITapGestureRecognizer *onetapGR;

- (IBAction)geoButtonClick;

- (void) makeRoomForKeyboard;

- (void) releaseRoomForKeyboard;

- (void)errorAlert:(NSString *) message;

- (void) setMapRegion:(CLLocationCoordinate2D )coordinate;

-(void) addAnnotation:(CLLocationCoordinate2D )coordinate title:(NSString *)title subtitle:(NSString *)subtitle;

-(BOOL)isAnnotationExist:(CLLocationCoordinate2D )coordinate;

-(void) modifyText:(CLLocationCoordinate2D )coordinate;

- (void)fetchDone:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error;
-(void) handleSearchResult:(NSDictionary *)result isLast:(BOOL)isLast;

-(NSString *) generateSubtitleForLocation:(NSString *)state city:(NSString *)city street:(NSString *)street;

-(BOOL)isLatitudeLongitudeInputValid;


- (void) addButtonClick:(id)sender;

- (IBAction) segmentedButtonClick:(id)sender;

- (IBAction) helpButtonClick:(id)sender;

- (void) removeMapAnnotation:(CLLocationCoordinate2D )user tobeAdd:(CLLocationCoordinate2D )tobeAdd;

-(void)layoutForCurrentOrientation:(BOOL)animated;


-(void)createADBannerView;
@end
