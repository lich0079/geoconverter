//
//  RootVC.m
//  geoconverter
//
//  Created by lich0079 on 11-6-27.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "RootVC.h"


@implementation RootVC

@synthesize geo,help,map,latitude,longitude,searchBar,banner,admobView,locationManager;//retain

@synthesize enableZoom,enableTap,onetapGR,isGeocoderUseNetwork,hasDrawLines;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    [super dealloc];
    self.latitude.delegate = nil;
    self.longitude.delegate = nil;
    self.searchBar.delegate = nil;
    self.map.delegate = nil;
    if(self.banner){
        self.banner.delegate=nil;
        [self.banner release];
    }
    if(self.admobView){
        self.admobView.delegate=nil;
        [self.admobView release];
    }
    [self.geo release];
    [self.map release];
    [self.latitude release];
    [self.longitude release];
    [self.searchBar release];
    if (self.locationManager) {
        [self.locationManager release];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.latitude.delegate = self;
    self.longitude.delegate = self;
    self.searchBar.delegate = self;
    self.map.delegate = self;

    self.enableTap = NO;
    self.enableZoom =NO;
    self.isGeocoderUseNetwork = NO;

    //remove searchbar background
    for (UIView *subview in self.searchBar.subviews){  
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){  
            [subview removeFromSuperview];  
            break;  
        } 
    }

    //set textfield value
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault synchronize];
    NSString *latitudeText =[userDefault valueForKey:@"latitude"];
   	NSString *longitudeText =[userDefault valueForKey:@"longitude"];

    if(latitudeText){
        latitude.text = latitudeText;
    }
    if(longitudeText){
        longitude.text = longitudeText;
    }

    //long press to get latitude longitude
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    lpress.allowableMovement = 10.0;
    [map addGestureRecognizer:lpress];//m_mapView是MKMapView的实例
    [lpress release];
    
    // one tap to dismiss keyboard 
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResp:)];
    tap.numberOfTapsRequired=1;
    [self.map addGestureRecognizer:tap];
    [tap release];
    
    
    if([userDefault objectForKey:@"version1.21helpchecked"] || [userDefault objectForKey:@"version1.0helpchecked"]){
        [self createAd];
    }
    
    //user location
    userLocation = CLLocationCoordinate2DMake(300.0f, 300.0f);
    [self startStandardUpdates];
}

//dismiss keyboard
-(void) resignFirstResp:(UIGestureRecognizer*)gestureRecognizer{
    if([searchBar isFirstResponder]){
        [searchBar resignFirstResponder];
    }else if([latitude isFirstResponder]){
        [self releaseRoomForKeyboard];
        [latitude resignFirstResponder];
    }else if([longitude isFirstResponder]){
        [self releaseRoomForKeyboard];
        [longitude resignFirstResponder];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.latitude.delegate = nil;
    self.longitude.delegate = nil;
    self.searchBar.delegate = nil;
    self.map.delegate = nil;
    if(self.banner){
        self.banner.delegate=nil;
        self.banner = nil;
    }
    if(self.admobView){
        self.admobView.delegate=nil;
        self.admobView = nil;
    }
    self.geo = nil;
    self.map = nil;
    self.latitude = nil;
    self.longitude = nil;
    self.searchBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManagerDelegate
- (void)startStandardUpdates {
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 500;
    [locationManager startUpdatingLocation];
    [self.locationManager release];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
//    CLogc;
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        userLocation = newLocation.coordinate;
        [self startFindPlaceMark:newLocation.coordinate];
    }
}

- (BOOL) isUserLocation:(CLLocationCoordinate2D ) coordinate{
    if (userLocation.latitude == 300.0f && userLocation.longitude == 300.0f) {
        return NO;
    }else if (userLocation.latitude == coordinate.latitude && userLocation.longitude == coordinate.longitude) {
        return  YES;
    }else {
        return NO;
    }
    
}

#pragma mark - textfield input
//raise the view's frame so the keyboard won't block the textfield
- (void)textFieldDidBeginEditing:(UITextField *)textField{
	if (self.latitude == textField || self.longitude == textField) {
        [self makeRoomForKeyboard];
	}
    
}

-(void) makeRoomForKeyboard{
    NSTimeInterval animationDuration = 0.30f;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.view.center = CGPointMake(320/2,480/2-200);
                     }];
}

-(void)releaseRoomForKeyboard{
    NSTimeInterval animationDuration = 0.30f;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.view.center = CGPointMake(160,250);
                     }];
}
//for latitude longitude textfield click "done" button
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(! [self isLatitudeLongitudeInputValid]){
    }else{
        [self releaseRoomForKeyboard];
        [textField resignFirstResponder];
    }
    return YES;
}

-(BOOL)isLatitudeLongitudeInputValid{
    float latiInput=  [latitude.text floatValue];
    float longiInput=  [longitude.text floatValue];
    
    if(latiInput >90 || latiInput < -90){
        [self errorAlert:NSLocalizedString(@"latitudelimit",@"latitude must between [-90,90]")];
        return NO;
    }else if(longiInput >180 || longiInput < -180){
        [self errorAlert:NSLocalizedString(@"longitudelimit",@"longitude must between [-180,180]")];
        return NO;
    }
    return YES;
}


#pragma mark - util 
-(void) modifyText:(CLLocationCoordinate2D )coordinate{
    latitude.text = [NSString stringWithFormat:@"%f",coordinate.latitude];
    longitude.text = [NSString stringWithFormat:@"%f",coordinate.longitude];
    //when convert float to string, there will be little missing value
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:latitude.text forKey:@"latitude"];
   	[userDefault setObject:longitude.text forKey:@"longitude"];
    [userDefault synchronize];
}

- (void) setMapRegion:(CLLocationCoordinate2D )coordinate{
    if(self.enableZoom){
        MKCoordinateRegion theRegion = map.region;
        theRegion.center.latitude = coordinate.latitude;
        theRegion.center.longitude = coordinate.longitude;
        theRegion.span.longitudeDelta = 1;
        theRegion.span.latitudeDelta = 1;
        @try {
            [map setRegion:theRegion animated:YES];
        }
        @catch (NSException *exception) {
            [self errorAlert:[exception description]];
        }
        @finally {
        }
    }else{
        @try {
            [map setCenterCoordinate:coordinate animated:YES];
        }
        @catch (NSException *exception) {
            [self errorAlert:[exception description]];
        }
        @finally {
        }
    }
}

- (void)errorAlert:(NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil message:message delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"ok",@"OK") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self dismissModalViewControllerAnimated:YES];
}

-(NSString *) generateSubtitleForLocation:(NSString *)state city:(NSString *)city street:(NSString *)street{
    NSMutableString *placeDesc = [NSMutableString stringWithString:@""];
    if(state ){
        [placeDesc appendFormat:@"%@",state];    
    }
    if(city){
        [placeDesc appendFormat:@" %@",city];
    }
    if(street){
        [placeDesc appendFormat:@" %@",street];
    }
    return [placeDesc description];
}

- (void) startFindPlaceMark:(CLLocationCoordinate2D )coordinate{
    MKReverseGeocoder* theGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
    theGeocoder.delegate = self;
    [theGeocoder start];
    BOOL isOtherUseNeiwork = [UIApplication sharedApplication].networkActivityIndicatorVisible ;
    if(!isOtherUseNeiwork){
//        CLog(@"use network");
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
        self.isGeocoderUseNetwork = YES;
    }
    if ([self isUserLocation:coordinate]) {
    }else{
        [self startLoading];
    }
}

-(void) addPlaceMark:(MKReverseGeocoder*)geocoder title:(NSString *)title subtitle:(NSString *)subtitle{
//    CLog(@"%f %f", geocoder.coordinate.latitude, geocoder.coordinate.longitude);
    [self removeMapAnnotation:geocoder.coordinate];
    [self addAnnotation:geocoder.coordinate title:title subtitle:subtitle];
    if (![self isUserLocation:geocoder.coordinate]) {
        [self modifyText:geocoder.coordinate];
    }
    [geocoder autorelease];
    if(self.isGeocoderUseNetwork){
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO; 
        self.isGeocoderUseNetwork = NO;
    }
}


#pragma mark -  MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)place {
//    CLog(@"-----%@   %@",geocoder,place);
    NSString *subtitle = [self generateSubtitleForLocation:place.administrativeArea city:place.locality street:place.thoroughfare];
    [self addPlaceMark:geocoder title:place.country subtitle:subtitle];
    [self stopLoading];
}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error {
//    CLog(@"%s %@",__FUNCTION__, [error localizedDescription]);
    [self addPlaceMark:geocoder title:NSLocalizedString(@"reverseGeocodererror", @"Could not retrieve the specified place information.") subtitle:nil];
    [self stopLoading];
}


#pragma mark -  MKMapViewDelegate annotation
-(BOOL)isAnnotationExist:(CLLocationCoordinate2D )coordinate{
    NSArray *anns = map.annotations;
    for (MKPointAnnotation *ann in anns) {
        // during string to float, there will be a little miss
        if((ann.coordinate.latitude + 0.00001 >= coordinate.latitude && ann.coordinate.latitude - 0.00001 <= coordinate.latitude)
           && (ann.coordinate.longitude + 0.00001 >= coordinate.longitude && ann.coordinate.longitude - 0.00001 <= coordinate.longitude)){
            return YES;
        }
    }
    return NO;
}

-(void) addAnnotation:(CLLocationCoordinate2D )coordinate title:(NSString *)title subtitle:(NSString *)subtitle {
    if(![self isAnnotationExist:coordinate]){
        MKPointAnnotation *ann = [[[MKPointAnnotation alloc] init] autorelease];
        ann.title = title;
        ann.subtitle = subtitle;
        ann.coordinate = coordinate;
        [map addAnnotation:ann];
    }
}
//remove other annotation so there will be only two annotation, the tobeAdd and the userlocation
- (void) removeMapAnnotation:(CLLocationCoordinate2D )tobeAdd{
    NSArray *anns = map.annotations;
 
    for (int j=0; j<[anns count]; j++) {
        id <MKAnnotation> an = [anns objectAtIndex:j];
        CLLocationCoordinate2D i = [an coordinate];
        if([self isUserLocation:i]){
        }else if (tobeAdd.latitude == i.latitude && tobeAdd.longitude == i.longitude){
        }else{
            MKPointAnnotation *ann = (MKPointAnnotation *)an;
            ann.title = nil;
            ann.subtitle = nil;
            [map removeAnnotation:an];
        }
    }
    [map setNeedsDisplay];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
    MKPinAnnotationView* pin = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    
    if(!pin){
        pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
        pin.pinColor = MKPinAnnotationColorRed;//设置大头针的颜色
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;

        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];

        [rightButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = rightButton;
    }else{
        pin.annotation = annotation;
    }
//    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_async(aQueue, ^{
//        sleep(1);
//        dispatch_async(dispatch_get_main_queue(),^{
//    [self.map selectAnnotation:annotation animated:YES];
//        });
//    });
    
    //set user location pin color 
    CLLocationCoordinate2D tobeAdd = [annotation coordinate];
    if([self isUserLocation:tobeAdd]){
        pin.pinColor = MKPinAnnotationColorPurple;
    }
    //////////////////////////////////////////
    
    return pin;
}
//use click the pin
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    CLLocationCoordinate2D coordinate =[view.annotation coordinate];
    [self modifyText:coordinate];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer {
//    CLog(@"%s %d",__FUNCTION__,gestureRecognizer.state);
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        //transfer coordinate
        CGPoint touchPoint = [gestureRecognizer locationInView:map];
        CLLocationCoordinate2D touchMapCoordinate = [map convertPoint:touchPoint toCoordinateFromView:map];
        if(![self isAnnotationExist:touchMapCoordinate]){
            [self setMapRegion:touchMapCoordinate];
            [self startFindPlaceMark:touchMapCoordinate];
        }
    }
}
//one tap to dismiss keyboard and convert point
- (void)tap:(UIGestureRecognizer*)gestureRecognizer {
    // CLog(@"%s",__FUNCTION__);
//    CLog(@"%d", gestureRecognizer.state);
    [self resignFirstResp:nil];
    CGPoint touchPoint = [gestureRecognizer locationInView:map];
    CLLocationCoordinate2D touchMapCoordinate = [map convertPoint:touchPoint toCoordinateFromView:map];
    [self modifyText:touchMapCoordinate];
}


- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
}
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
//    [self errorAlert:[error localizedDescription]];
}

#pragma mark -  add OverLayView
-(void) addLatitudeAndLongitudeOverLayView {
    for (int i=0; i<=18; i++) {
        CLLocationCoordinate2D lats[2];
        float lat = 90-i*10;
        lats[0] = CLLocationCoordinate2DMake(lat,179);
        lats[1] = CLLocationCoordinate2DMake(lat,-179);
        MKPolyline *overlay = [MKPolyline polylineWithCoordinates:lats count:2];
        [self.map addOverlay:overlay];
    }
    
    for (int i=0; i<=36; i++) {
        CLLocationCoordinate2D longs[2];
        float longi = 180-i*10;
        longs[0] = CLLocationCoordinate2DMake(89,longi);
        longs[1] = CLLocationCoordinate2DMake(-89,longi);
        [self.map addOverlay:[MKPolyline polylineWithCoordinates:longs count:2]];
    }
    for (int i=0; i<=18; i++) {
        float lat = 90-i*10;
        for (int i=0; i<=36; i++) {
            float longi = 180-i*10;
            LaLoOverlay *test = [[LaLoOverlay alloc]init];
            test.coordinate = CLLocationCoordinate2DMake(lat, longi);
            [self.map addOverlay:test];
            [test autorelease];
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:NSClassFromString(@"LaLoOverlay")]) {
        LaLoOverlayView *view = [[[LaLoOverlayView alloc] initWithOverlay:overlay]autorelease];
        return view;
    }
    
    
    MKPolylineView *polyLineView = [[[MKPolylineView alloc] initWithOverlay:overlay] autorelease];
    CLLocationCoordinate2D coordinate = [overlay coordinate];
    if (coordinate.latitude == 0) {
        polyLineView.strokeColor = [UIColor greenColor];
    }else{
        polyLineView.strokeColor = [UIColor blueColor];
    }
    
    if (coordinate.latitude == 0 && coordinate.longitude == 0) {
        polyLineView.strokeColor = [UIColor redColor];
    }
    polyLineView.lineWidth = 1.0;
    return polyLineView;
}

#pragma mark -  UISearchBarDelegate 
//query yahoo api to get the geo info  or use corelocation in ios5
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
    CLog(@"ios5");
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    [self startLoading];
    [geocoder geocodeAddressString:self.searchBar.text
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     int count = [placemarks count];
                     if(count > 0 ){
                         //remove other pin
                         CLLocationCoordinate2D coordinate = {0,0};
                         [self removeMapAnnotation:coordinate];
                         for (int i = 0; i < count; i++) {
                             CLPlacemark *location = [placemarks objectAtIndex:i];
                             if(i == count - 1 ){
                                 [self handleSearchCLPlacemark:location isLast:YES];
                             }else{
                                 [self handleSearchCLPlacemark:location isLast:NO];
                             }
                         }
                     }else{
                         [self errorAlert:NSLocalizedString(@"noresult",@"no result")];
                     }
                     [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                     [self stopLoading];
                 }];
    [geocoder autorelease];
#else
    CLog(@"ios4");
    
    NSString *locale = [NSString stringWithFormat:@"&locale=%@",[[NSLocale autoupdatingCurrentLocale] localeIdentifier]];
    NSString *urlString=[NSString stringWithFormat:@"%@%@%@",@"http://where.yahooapis.com/geocode?appid=V1YpaJ7k&flags=j&q=",[self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],locale];
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];  
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetchDone:finishedWithData:error:)];  
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    [self startLoading];  
#endif
}

//parse geo info data and add pin
- (void)fetchDone:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error{
    if(error){  
        [self errorAlert:[error localizedDescription]];
        [self stopLoading];
    }else{  
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(aQueue, ^{
            NSString* aStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding] ;  
            SBJsonParser *parse = [[SBJsonParser alloc] init];
            NSDictionary *result = [parse objectWithString:aStr];
            [parse release];
            [aStr release];
            NSDictionary *resultSet   = [result valueForKey:@"ResultSet"];
            NSArray *resultsArray = [resultSet valueForKey:@"Results"];
            dispatch_async(dispatch_get_main_queue(),^{
                int count = [resultsArray count];
                if(count > 0 ){
                    //remove other pin
                    CLLocationCoordinate2D coordinate = {0,0};
                    [self removeMapAnnotation:coordinate];
                    for (int i = 0; i < count; i++) {
                        NSDictionary *location = [resultsArray objectAtIndex:i];
                        if(i == count - 1 ){
                            [self handleSearchResult:location isLast:YES];
                        }else{
                            [self handleSearchResult:location isLast:NO];
                        }
                    }
                }else{
                    [self errorAlert:NSLocalizedString(@"noresult",@"no result")];
                }
                [self stopLoading];
            });
        });
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}

-(void) handleSearchResult:(NSDictionary *)result isLast:(BOOL)isLast{
    NSString *la = [result valueForKey:@"latitude"];
    NSString *lo = [result valueForKey:@"longitude"];
    NSString *country = [result valueForKey:@"country"];
    NSString *state = [result valueForKey:@"state"];
    NSString *city = [result valueForKey:@"city"];
    NSString *street = [result valueForKey:@"street"];
    if([street length] == 0){
        street = [result valueForKey:@"line2"];
    }
    NSString *subtitle = [self generateSubtitleForLocation:state city:city street:street];
    CLLocationCoordinate2D coordinate = {[la floatValue],[lo floatValue]};
    [self addAnnotation:coordinate title:country subtitle:subtitle];
    if(isLast){
        [self setMapRegion:coordinate];
        [self modifyText:coordinate];
    }
    
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
-(void) handleSearchCLPlacemark:(CLPlacemark *)result isLast:(BOOL)isLast{
//    CLog(@"%@", result);
//    CLog(@"%@", result.name);
//    CLog(@"%@", result.ISOcountryCode);
//    CLog(@"%@", result.country);
//    CLog(@"%@", result.postalCode);
//    CLog(@"%@", result.administrativeArea);
//    CLog(@"%@", result.subAdministrativeArea);
//    CLog(@"%@", result.locality);
//    CLog(@"%@", result.subLocality);
//    CLog(@"%@", result.thoroughfare);
//    CLog(@"%@", result.subThoroughfare);
//    CLog(@"%@", result.region);
//    CLog(@"%@", result.inlandWater);
//    CLog(@"%@", result.ocean);
    NSString *country = result.country;
    NSString *state = result.administrativeArea;
    if (!result.administrativeArea && result.subAdministrativeArea) {
        state = result.subAdministrativeArea;
    }
    NSString *city = result.locality;
    if (!result.locality && result.subLocality) {
        city = result.subLocality;
    }
    NSString *street = result.thoroughfare;
    if (result.thoroughfare && result.subThoroughfare) {
        street = [street stringByAppendingFormat:@" %@",result.subThoroughfare];
    }else if (result.subThoroughfare){
        street = result.subThoroughfare;
    }
    if([street length] == 0){
        street = result.name;
    }
    NSString *subtitle = [self generateSubtitleForLocation:state city:city street:street];
    CLLocationCoordinate2D coordinate = result.location.coordinate;
    [self addAnnotation:coordinate title:country subtitle:subtitle];
    if(isLast){
        [self setMapRegion:coordinate];
        [self modifyText:coordinate];
    }
    
}
#endif

#pragma mark -  UIControl button click
- (IBAction)geoButtonClick {
//    CLog(@"%s", __FUNCTION__);
    if(![self isLatitudeLongitudeInputValid]){
        return;
    }
    float latiInput=  [latitude.text floatValue];
    float longiInput=  [longitude.text floatValue];
    //if == 90 there will be a calayer bond error
    if(latiInput > 89){
        latiInput = 89;
    }else if(latiInput < -89){
        latiInput = -89;
    }
    CLLocationCoordinate2D coordinate ={latiInput,longiInput};
    [self resignFirstResp:nil];
    [self setMapRegion:coordinate];
    //if the pin don't exist, we put the pin    
    if(![self isAnnotationExist:coordinate]){
        [self startFindPlaceMark:coordinate];
    }
}

- (IBAction)converterClick:(id)sender {
    ConverterVC *controller= [[[ConverterVC alloc]init] autorelease];
    controller.rootVC = self;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:controller animated:YES];
}
- (void) addButtonClick:(id)sender{
    UIButton *button = sender;
    MKPinAnnotationView *pin = (MKPinAnnotationView *)button.superview.superview;
    CLLocationCoordinate2D coordinate = [pin.annotation coordinate];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%f, %f",coordinate.latitude,coordinate.longitude];
    [self errorAlert:NSLocalizedString(@"addtopasteboard", @"add to pasteboard")];
}

- (IBAction) segmentedButtonClick:(id)sender{
    UISegmentedControl *scbutton = sender;
    int index = scbutton.selectedSegmentIndex;

    if(index == 0){
        map.mapType = MKMapTypeStandard;
    }else{
        map.mapType = MKMapTypeHybrid;
    }

    
}

- (IBAction) helpButtonClick:(id)sender{
    HelpVC *helpVC= [[[HelpVC alloc]init] autorelease];
    helpVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    helpVC.delegate = self;
    [self presentModalViewController:helpVC animated:YES];
}

- (void)dismissModal:(HelpVC *)helpVC{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark ADBannerViewDelegate methods
// make room for show iAd or admob
-(void)layoutForCurrentOrientation:(BOOL)animated isLoadSuccess:(BOOL)isLoadSuccess
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;

    CGRect contentFrame = map.frame;
	
    CGPoint bannerOrigin ;
    if((self.banner && self.banner.bannerLoaded)  ||  (self.admobView && isLoadSuccess)){
        contentFrame.size.height = 322;
        bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    }else{
        contentFrame.size.height = 372;
        bannerOrigin = CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds));
    }
    
    __block RootVC *tmp = self;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         map.frame = contentFrame;
                         [map layoutIfNeeded];
                         if(tmp.banner){
                             tmp.banner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, tmp.banner.frame.size.width, tmp.banner.frame.size.height);
                         }else{
                             tmp.admobView.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, tmp.admobView.frame.size.width, tmp.admobView.frame.size.height);
                         }
                     }];
}

-(void)createADBannerView {
	NSString *contentSize = (&ADBannerContentSizeIdentifierPortrait != nil) ?ADBannerContentSizeIdentifierPortrait:ADBannerContentSizeIdentifier320x50;
    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.view.bounds));
    
    self.banner = [[ADBannerView alloc] initWithFrame:frame];
    [self.banner release];
    self.banner.delegate = self;
    self.banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
	self.banner.requiredContentSizeIdentifiers = (&ADBannerContentSizeIdentifierPortrait != nil) ?
    [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] : 
    [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
    [self.view addSubview:banner];
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    CLog(@"%s",__FUNCTION__);
    [self layoutForCurrentOrientation:YES isLoadSuccess:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    CLog(@"%s",__FUNCTION__);
    [self layoutForCurrentOrientation:YES isLoadSuccess:NO];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

#pragma mark admob methods   
-(void)createAdmobGADBannerView{
    CLog(@"%s",__FUNCTION__);
    self.admobView = [[GADBannerView alloc]
                                  initWithFrame:CGRectMake(0.0,
                                                           self.view.frame.size.height,
                                                           GAD_SIZE_320x50.width,
                                                           GAD_SIZE_320x50.height)];
    [self.admobView release];
    admobView.adUnitID = @"a14e1a8af59a910";
    admobView.rootViewController = self;
    admobView.delegate = self;
    [self.view addSubview:admobView];
    GADRequest *request = [GADRequest request];
    
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,                               // Simulator
                           @"28ab37c3902621dd572509110745071f0101b124",    // Test iPhone 3G 3.0.1
                           @"8cf09e81ef3ec5418c3450f7954e0e95db8ab200",    // Test iPod 4.3.1
                           nil];
    [admobView loadRequest:request];
    [admobView release];

}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
//    CLog(@"%s",__FUNCTION__);
    [self layoutForCurrentOrientation:YES isLoadSuccess:YES];
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
//        CLog(@"%s %@",__FUNCTION__, [error localizedDescription]);
    [self layoutForCurrentOrientation:YES isLoadSuccess:NO];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView{
}
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
}


#pragma mark decide which ad to use
- (void) createAd{
    NSString *timezone = [[NSTimeZone localTimeZone]name];
//    timezone = @"America/Los_Angeles";
    if([timezone rangeOfString:@"America/Los_Angeles"].location== 0
       || [timezone rangeOfString:@"Europe/Rome"].location== 0
       || [timezone rangeOfString:@"Europe/San_Marino"].location== 0
       || [timezone rangeOfString:@"Europe/Berlin"].location== 0
       || [timezone rangeOfString:@"Europe/London"].location== 0
       || [timezone rangeOfString:@"Europe/Madrid"].location== 0
       || [timezone rangeOfString:@"Europe/Paris"].location== 0
       || [timezone rangeOfString:@"Asia/Tokyo"].location== 0
       || [timezone rangeOfString:@"America/New_York"].location== 0
       || [timezone rangeOfString:@"America/Chicago"].location== 0  
       || [timezone rangeOfString:@"America/Phoenix"].location== 0
       || [timezone rangeOfString:@"America/Boise"].location== 0
       || [timezone rangeOfString:@"America/Denver"].location== 0
       || [timezone rangeOfString:@"America/Detroit"].location== 0
       || [timezone rangeOfString:@"America/Grand_Turk"].location== 0    
       || [timezone rangeOfString:@"America/Indiana/Indianapolis"].location== 0
       || [timezone rangeOfString:@"America/Indiana/Knox"].location== 0
       || [timezone rangeOfString:@"America/Indiana/Marengo"].location== 0
       || [timezone rangeOfString:@"America/Indiana/Petersburg"].location== 0
       || [timezone rangeOfString:@"America/Indiana/Tell_City"].location== 0
       || [timezone rangeOfString:@"America/Indiana/Vevay"].location== 0
       || [timezone rangeOfString:@"America/Indiana/Vincennes"].location== 0
       || [timezone rangeOfString:@"America/Indiana/Winamac"].location== 0
       || [timezone rangeOfString:@"America/Kentucky/Louisville"].location== 0
       || [timezone rangeOfString:@"America/Kentucky/Monticello"].location== 0
       || [timezone rangeOfString:@"America/Menominee"].location== 0    
       || [timezone rangeOfString:@"America/Nome"].location== 0
       || [timezone rangeOfString:@"America/North_Dakota/Center"].location== 0
       || [timezone rangeOfString:@"America/North_Dakota/New_Salem"].location== 0
       || [timezone rangeOfString:@"America/Rainy_River"].location== 0
       || [timezone rangeOfString:@"America/Shiprock"].location== 0
       || [timezone rangeOfString:@"America/St_Johns"].location== 0
       || [timezone rangeOfString:@"America/Yakutat"].location== 0
       
       ){
        if (banner == nil) {
            [self createADBannerView];
        }
    }else{
        if(admobView == nil) {
            [self createAdmobGADBannerView];
        }
    }
}

#pragma mark loadIndicator
-(void) startLoading{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
}

-(void) stopLoading{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end