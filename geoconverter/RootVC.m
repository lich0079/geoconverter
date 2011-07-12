//
//  RootVC.m
//  geoconverter
//
//  Created by lich0079 on 11-6-27.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "RootVC.h"


@implementation RootVC

@synthesize geo,map,latitude,longitude,searchBar,banner,admobView;//retain

@synthesize enableZoom,enableTap,onetapGR;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    [super dealloc];
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

    //remove searchbar background
    for (UIView *subview in self.searchBar.subviews){  
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){  
            [subview removeFromSuperview];  
            break;  
        } 
    }

    map.showsUserLocation = YES;
    map.mapType = MKMapTypeStandard;

    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault synchronize];
    NSString *latitudeText =[userDefault valueForKey:@"latitude"];
   	NSString *longitudeText =[userDefault valueForKey:@"longitude"];

    if(latitudeText){
        latitude.text = latitudeText;
//        CLog(@"kvc %@",[latitude valueForKey:@"text"]);
    }
    if(longitudeText){
        longitude.text = longitudeText;
    }

    
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    lpress.allowableMovement = 10.0;
    [map addGestureRecognizer:lpress];//m_mapView是MKMapView的实例
    [lpress release];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResp:)];
    tap.numberOfTapsRequired=1;
    [self.map addGestureRecognizer:tap];
    [tap release];
    
    [self createAd];
}

-(void) resignFirstResp:(UIGestureRecognizer*)gestureRecognizer{
    [searchBar resignFirstResponder];
}

- (void)viewDidUnload
{

    [super viewDidUnload];
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

    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - textfield input

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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:latitude.text forKey:@"latitude"];
   	[userDefault setObject:longitude.text forKey:@"longitude"];
    [userDefault synchronize];
}

- (void) setMapRegion:(CLLocationCoordinate2D )coordinate{

    MKCoordinateRegion theRegion = map.region;
    theRegion.center.latitude = coordinate.latitude;
    theRegion.center.longitude = coordinate.longitude;
    if(self.enableZoom){
        theRegion.span.longitudeDelta = 1;
        theRegion.span.latitudeDelta = 1;
    }
    @try {
        [map setRegion:theRegion animated:YES];
    }
    @catch (NSException *exception) {
        [self errorAlert:[exception description]];
        
    }
    @finally {
        
    }
}

- (void)errorAlert:(NSString *) message {
    //NSLocalizedString(@"error",@"Error") 
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
- (IBAction)geoButtonClick {
    
    if(![self isLatitudeLongitudeInputValid]){
        return;
    }
    
    float latiInput=  [latitude.text floatValue];
    float longiInput=  [longitude.text floatValue];


    //if = 90 there will be a calayer bond error
    if(latiInput > 89){
        latiInput = 89;
    }else if(latiInput < -89){
        latiInput = -89;
    }
    CLLocationCoordinate2D coordinate ={latiInput,longiInput};
    [self setMapRegion:coordinate];
    

    if(![self isAnnotationExist:coordinate]){
        MKReverseGeocoder* theGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
        
        theGeocoder.delegate = self;
        [theGeocoder start];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;  

    }
 
        
}



#pragma mark -  MKReverseGeocoderDelegate



- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)place
{
//    CLog(@"-----%@   %@",geocoder,place);

    NSString *subtitle = [self generateSubtitleForLocation:place.administrativeArea city:place.locality street:place.thoroughfare];
    [self removeMapAnnotation:geocoder.coordinate];
    [self addAnnotation:geocoder.coordinate title:place.country subtitle:subtitle];
    
    [self modifyText:geocoder.coordinate];
    [geocoder release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;  
 

}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error
{
//    CLog(@"%s",__FUNCTION__);
    [self removeMapAnnotation:geocoder.coordinate];
    [self addAnnotation:geocoder.coordinate title:NSLocalizedString(@"reverseGeocodererror", @"Could not retrieve the specified place information.") subtitle:nil];
    [self modifyText:geocoder.coordinate];
    [geocoder release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;  

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
//    CLog(@"%@ %@",title,subtitle);
    if(![self isAnnotationExist:coordinate]){
        MKPointAnnotation *ann = [[[MKPointAnnotation alloc] init] autorelease];
        ann.title = title;
        ann.subtitle = subtitle;
        ann.coordinate = coordinate;

        [map addAnnotation:ann];
    }
}

- (void) removeMapAnnotation:(CLLocationCoordinate2D )tobeAdd{
    CLLocationCoordinate2D user = map.userLocation.coordinate;
    NSArray *anns = map.annotations;
 
    for (int j=0; j<[anns count]; j++) {
        
        id <MKAnnotation> an = [anns objectAtIndex:j];
        CLLocationCoordinate2D i = [an coordinate];

        if(user.latitude == i.latitude && user.longitude == i.longitude){
            
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

    
    //don't let user location pin setup by this method 
    CLLocationCoordinate2D user = map.userLocation.coordinate;
    CLLocationCoordinate2D tobeAdd = [annotation coordinate];
    if(user.latitude == tobeAdd.latitude && user.longitude == tobeAdd.longitude){
        return nil;
    }
    //////////////////////////////////////////
    
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
//    [annotation autorelease];
    return pin;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
        
    CLLocationCoordinate2D coordinate =[view.annotation coordinate];
    [self modifyText:coordinate];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer
{
//    CLog(@"%s %d",__FUNCTION__,gestureRecognizer.state);

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        //            //transfer coordinate
        CGPoint touchPoint = [gestureRecognizer locationInView:map];
        CLLocationCoordinate2D touchMapCoordinate = [map convertPoint:touchPoint toCoordinateFromView:map];
        
        //  CLog(@"%f %f",touchMapCoordinate.latitude,touchMapCoordinate.longitude);
        
        if(![self isAnnotationExist:touchMapCoordinate]){
            [self setMapRegion:touchMapCoordinate];
            MKReverseGeocoder* theGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:touchMapCoordinate];
            
            theGeocoder.delegate = self;
            [theGeocoder start];
        }
    }

}

- (void)tap:(UIGestureRecognizer*)gestureRecognizer
{
    // CLog(@"%s",__FUNCTION__);
//    CLog(@"%d", gestureRecognizer.state);
    
    [searchBar resignFirstResponder];

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
    [self errorAlert:[error localizedDescription]];
}
#pragma mark -  UISearchBarDelegate  
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
//        CLog(@"%s  %@",__FUNCTION__, self.searchBar.text);
    [self.searchBar resignFirstResponder];
    NSString *locale = [NSString stringWithFormat:@"&locale=%@",[[NSLocale autoupdatingCurrentLocale] localeIdentifier]];
    NSString *urlString=[NSString stringWithFormat:@"%@%@%@",@"http://where.yahooapis.com/geocode?appid=V1YpaJ7k&flags=j&q=",[self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],locale];


    
    NSURL *requestURL = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];  
    
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetchDone:finishedWithData:error:)];  
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    


}


- (void)fetchDone:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error{
    
    if(error){  
        [self errorAlert:[error localizedDescription]];
    }else{  
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(aQueue, ^{
            NSString* aStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding] ;  
            //                CLog(@"%@  %d",aStr, [resultsArray count]);
            SBJsonParser *parse = [[SBJsonParser alloc] init];
            NSDictionary *result = [parse objectWithString:aStr];
            [parse release];
            [aStr release];
            NSDictionary *resultSet   = [result valueForKey:@"ResultSet"];
            NSArray *resultsArray = [resultSet valueForKey:@"Results"];
            dispatch_async(dispatch_get_main_queue(),^{
                int count = [resultsArray count];
                if(count > 0 ){
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
#pragma mark -  UIControl

- (void) addButtonClick:(id)sender{
    UIButton *button = sender;
    MKPinAnnotationView *pin = (MKPinAnnotationView *)button.superview.superview;
    CLLocationCoordinate2D coordinate = [pin.annotation coordinate];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%f, %f",coordinate.latitude,coordinate.longitude];
    [self errorAlert:NSLocalizedString(@"addtopasteboard", @"add to pasteboard")];
    //    CLog(@"%f %f",coordinate.latitude,coordinate.longitude);
    
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
    HelpVC *help= [[[HelpVC alloc]init] autorelease];
    help.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    help.delegate = self;
    [self presentModalViewController:help animated:YES];
}

- (void)dismissModal:(HelpVC *)helpVC{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark ADBannerViewDelegate methods
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

-(void)createADBannerView
{
    
	NSString *contentSize = (&ADBannerContentSizeIdentifierPortrait != nil) ?ADBannerContentSizeIdentifierPortrait:ADBannerContentSizeIdentifier320x50;


    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.view.bounds));
    
    banner = [[[ADBannerView alloc] initWithFrame:frame] autorelease];
    banner.delegate = self;
    banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;

    
	banner.requiredContentSizeIdentifiers = (&ADBannerContentSizeIdentifierPortrait != nil) ?
    [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] : 
    [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
    
        // At this point the ad banner is now be visible and looking for an ad.
    [self.view addSubview:banner];
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    CLog(@"%s",__FUNCTION__);
    [self layoutForCurrentOrientation:YES isLoadSuccess:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    CLog(@"%s",__FUNCTION__);
    [self layoutForCurrentOrientation:YES isLoadSuccess:NO];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

#pragma mark admob methods   
-(void)createAdmobGADBannerView{
        CLog(@"%s",__FUNCTION__);
    
    self.admobView = [[GADBannerView alloc]
                                  initWithFrame:CGRectMake(0.0,
                                                           self.view.frame.size.height,
                                                           GAD_SIZE_320x50.width,
                                                           GAD_SIZE_320x50.height)];
    admobView.adUnitID = @"a14e1a8af59a910";
    admobView.rootViewController = self;
    admobView.delegate = self;
    admobView.center = CGPointMake(160, 250);
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
    CLog(@"%s",__FUNCTION__);
    [self layoutForCurrentOrientation:YES isLoadSuccess:YES];
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
        CLog(@"%s %@",__FUNCTION__, [error localizedDescription]);
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
    
//    timezone = @"America/xxx";
    if([timezone rangeOfString:@"America/"].location== 0
       || [timezone rangeOfString:@"Europe/Rome"].location== 0
       || [timezone rangeOfString:@"Europe/San_Marino"].location== 0
       || [timezone rangeOfString:@"Europe/Berlin"].location== 0
       || [timezone rangeOfString:@"Europe/London"].location== 0
       || [timezone rangeOfString:@"Europe/Madrid"].location== 0
       || [timezone rangeOfString:@"Europe/Paris"].location== 0
       || [timezone rangeOfString:@"Asia/Tokyo"].location== 0){
        if (banner == nil) {
            [self createADBannerView];
        }
    }else{
        if(admobView == nil) {
            [self createAdmobGADBannerView];
        }

    }
}
    
@end




