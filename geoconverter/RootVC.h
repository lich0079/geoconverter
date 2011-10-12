//
//  RootVC.h
//  geoconverter
//
//  Created by lich0079 on 11-6-27.
//  Copyright 2011年 ibm. All rights reserved.
//


#import "GTMHTTPFetcher.h"
#import "SBJsonParser.h"
#import "HelpVC.h"
#import "GADBannerView.h"
#import "LaLoOverlay.h"
#import "LaLoOverlayView.h"
#import "MBProgressHUD.h"
#import "ConverterVC.h"


@interface RootVC : UIViewController  <UITextFieldDelegate,MKReverseGeocoderDelegate,MKMapViewDelegate,UISearchBarDelegate,HelpVCDelegate,ADBannerViewDelegate,GADBannerViewDelegate,CLLocationManagerDelegate> {
    CLLocationCoordinate2D userLocation;
}

@property (nonatomic, retain) IBOutlet UIButton *geo;

@property (nonatomic, retain) IBOutlet UIButton *help;

@property (nonatomic, retain) IBOutlet UITextField *latitude;

@property (nonatomic, retain) IBOutlet UITextField *longitude;

@property (nonatomic, retain) IBOutlet MKMapView *map;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) ADBannerView *banner;
@property (nonatomic, retain) GADBannerView *admobView;

@property (nonatomic, retain) CLLocationManager *locationManager;



@property BOOL enableZoom;

@property BOOL enableTap;

@property BOOL isGeocoderUseNetwork;

@property BOOL hasDrawLines;

@property (nonatomic, assign) UITapGestureRecognizer *onetapGR;

- (IBAction)geoButtonClick;
- (IBAction)converterClick:(id)sender;

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

- (void) removeMapAnnotation:(CLLocationCoordinate2D )tobeAdd;

-(void)layoutForCurrentOrientation:(BOOL)animated isLoadSuccess:(BOOL)isLoadSuccess;


-(void)createADBannerView;

-(void)createAdmobGADBannerView;

- (void) createAd;

- (void) startFindPlaceMark:(CLLocationCoordinate2D )coordinate;

-(void) addPlaceMark:(MKReverseGeocoder*)geocoder title:(NSString *)title subtitle:(NSString *)subtitle;

-(void) startLoading;

-(void) stopLoading;

-(void) addLatitudeAndLongitudeOverLayView;

- (void)startStandardUpdates;

- (BOOL) isUserLocation:(CLLocationCoordinate2D ) coordinate;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
- (void) handleSearchCLPlacemark:(CLPlacemark *)result isLast:(BOOL)isLast;
#endif
@end
