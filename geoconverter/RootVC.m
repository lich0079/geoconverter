//
//  RootVC.m
//  geoconverter
//
//  Created by lich0079 on 11-6-27.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "RootVC.h"


@implementation RootVC

@synthesize geo,map,latitude,longitude,searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"%s %@",__FUNCTION__, [[NSLocale autoupdatingCurrentLocale] localeIdentifier]);
    self.latitude.delegate = self;
    self.longitude.delegate = self;
    self.searchBar.delegate = self;

    //remove searchbar background
    for (UIView *subview in self.searchBar.subviews){  
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){  
            [subview removeFromSuperview];  
            break;  
        } 
    }

    map.showsUserLocation = YES;
    map.mapType = MKMapTypeStandard;
    map.delegate = self;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *latitudeText =[userDefault valueForKey:@"latitude"];
   	NSString *longitudeText =[userDefault valueForKey:@"longitude"];
//    NSLog(@"read: %@ %@",latitudeText,longitudeText);
    if(latitudeText){
        latitude.text = latitudeText;
    }
    if(longitudeText){
        longitude.text = longitudeText;
    }

    
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    lpress.allowableMovement = 10.0;
    [map addGestureRecognizer:lpress];//m_mapView是MKMapView的实例
    [lpress release];
    

}

- (void)viewDidUnload
{

    [super viewDidUnload];
    [geo release];
    [map release];
    [latitude release];
    [longitude release];
    [searchBar release];

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
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.center = CGPointMake(320/2,480/2-200);
    [UIView commitAnimations];
}

-(void)releaseRoomForKeyboard{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.center = CGPointMake(160,250);
    
    [UIView commitAnimations];
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
//    NSLog(@"-----%@   %@",geocoder,place);

    NSString *subtitle = [self generateSubtitleForLocation:place.administrativeArea city:place.locality street:place.thoroughfare];
    
    [self addAnnotation:geocoder.coordinate title:place.country subtitle:subtitle];
    
    [self modifyText:geocoder.coordinate];
    [geocoder release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;  
 

}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error
{
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
//            NSLog(@"isAnnotationExist");
            return YES;
        }
    }
//    NSLog(@"isNotAnnotationExist");
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

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
    MKPinAnnotationView* pin = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    
    //don't let user location pin setup by this method 
    CLLocationCoordinate2D c = map.userLocation.coordinate;
    CLLocationCoordinate2D b = [annotation coordinate];
    if(c.latitude == b.latitude && c.longitude == b.longitude){
        return nil;
    }
    //////////////////////////////////////////
    
    
    if(!pin){

        pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
        pin.pinColor = MKPinAnnotationColorRed;//设置大头针的颜色
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;

        //pin.draggable = YES;
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];

        [rightButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = rightButton;
    }else{
        pin.annotation = annotation;
    }
   // [annotation autorelease];
    return pin;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
        
    CLLocationCoordinate2D coordinate =[view.annotation coordinate];
    [self modifyText:coordinate];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer
{
   // NSLog(@"%s",__FUNCTION__);
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
//        NSLog(@"UIGestureRecognizerStateEnded");
        return;
    }
    
    //transfer coordinate
    CGPoint touchPoint = [gestureRecognizer locationInView:map];
    CLLocationCoordinate2D touchMapCoordinate = [map convertPoint:touchPoint toCoordinateFromView:map];
    
  //  NSLog(@"%f %f",touchMapCoordinate.latitude,touchMapCoordinate.longitude);
    
    if(![self isAnnotationExist:touchMapCoordinate]){
        [self setMapRegion:touchMapCoordinate];
        MKReverseGeocoder* theGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:touchMapCoordinate];
        
        theGeocoder.delegate = self;
        [theGeocoder start];
    }

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
    
//        NSLog(@"%s  %@",__FUNCTION__, self.searchBar.text);
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
        NSString* aStr = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];  
//                NSLog(@"%@  %d",aStr, [resultsArray count]);
        SBJsonParser *parse = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *result = [parse objectWithString:aStr];
        NSDictionary *resultSet   = [result valueForKey:@"ResultSet"];
        NSArray *resultsArray = [resultSet valueForKey:@"Results"];
        
        int count = [resultsArray count];
        if(count > 0 ){
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

           
        
        [aStr release];

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
    //    NSLog(@"%f %f",coordinate.latitude,coordinate.longitude);
    
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
@end
