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

@interface RootVC : UIViewController  <UITextFieldDelegate,MKReverseGeocoderDelegate,MKMapViewDelegate,UISearchBarDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIButton *geo;

@property (nonatomic, retain) IBOutlet UITextField *latitude;

@property (nonatomic, retain) IBOutlet UITextField *longitude;

@property (nonatomic, retain) IBOutlet MKMapView *map;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;



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
@end
