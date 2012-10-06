//
//  MSUNavViewController.m
//  MSUNav
//
//  Created by Nicholas Slocum on 1/22/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define baseURL [NSString stringWithString:@"https://dev.gis.msu.edu/FlexData/wayfinding?QUERY="]

#import "MSUNavViewController.h"
#import <CoreLocation/CoreLocation.h>


// Add methods to NSDictionary
// -----------------------------------------------
@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)

+ (NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

- (NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions
                                                  error:&error];
    if (error != nil) return nil;
    return result;
}
@end
// -----------------------------------------------


@implementation MSUNavViewController
@synthesize mapView = _mapView;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize buildingName = _buildingName;
@synthesize buildingID = _buildingID;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (NSData*)appendJSONDictionary:(NSDictionary*)jsonDict 
                          toURL:(NSString*)url
{
    NSData* jsonData = [jsonDict toJSON];
    
    NSString* jsonString = [[NSString alloc]initWithData:jsonData 
                                                encoding:NSUTF8StringEncoding];
    
    NSString* completeURL = [url stringByAppendingString:jsonString];
    NSString* escapedUrlString = [completeURL stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    NSURL* escapedUrl = [NSURL URLWithString:escapedUrlString];
    
    //    NSData *data = [NSData dataWithContentsOfURL: escapedUrl];
    return [NSData dataWithContentsOfURL: escapedUrl];
}

- (NSDictionary*)fetchedData:(NSData *)responseData
{
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    //    // Check if the query was successful
    //    if ([[json objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]) {
    //        NSLog(@"status: %@", [json objectForKey:@"STATUS"]);
    //        _humanReadable.text = [json objectForKey:@"STATUS"];
    //    }
    //    else {
    //    }
    
    NSDictionary* content = [json objectForKey:@"CONTENT"];
    return content;
}

- (NSNumber*)getBuildingID:(NSString*)buildingName
{
    // Construct the query to get the destination building's id
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"NAMESEARCH", @"QUERYTYPE",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            buildingName,  @"SEARCHTERM", nil],
                           @"ARGUMENTS", nil];
    
    NSData* data = [self appendJSONDictionary:query toURL:baseURL];
//    NSLog(@"data: %@", data);
    
    NSDictionary* content = [self fetchedData:data];  // TODO: should be executed in a seperate thread
    
    NSNumber* buildingID = [[[content objectForKey:@"DATA"] objectAtIndex:0] objectForKey:@"OBJECT_ID"];
    return buildingID;
//    return [NSNumber numberWithInt:4];
}

- (NSArray*)getPathToDestination:(NSNumber*)buildingID 
                    fromLatitude:(NSNumber*)latitude
                    andLongitude:(NSNumber*)longitude
{
    // Construct the json query
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"FINDPATH", @"QUERYTYPE",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             latitude,  @"NORTHING",
                             longitude, @"EASTING",
                             @"LOCATION", @"TYPE", nil], @"FROM",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"BUILDING",   @"OBJECT_TYPE",
                             buildingID,       @"OBJECT_ID",
                             @"IDENTIFIER", @"TYPE", nil], @"TO", 
                            [NSArray arrayWithObjects: @"SIDEWALK", @"CWSTR", @"CROSSWALK", @"CWSGSTR", nil], @"PATHTYPES", nil],
                           @"ARGUMENTS", nil];
    
    NSData* data = [self appendJSONDictionary:query toURL:baseURL];
    
    NSDictionary* content = [self fetchedData:data];    // TODO: should be executed in a seperate thread
    
    return [content objectForKey:@"GEOMETRY"];
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView* view = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        view.fillColor   = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        view.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        view.lineWidth = 3;
        return view;
    }
    else if([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView* view = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
        view.lineWidth = 5;
        view.strokeColor = [UIColor blueColor];
        return view;
    }
    else return nil;
}


//- (void)startStandardUpdates
//{
//    // Create the location manager if this object does not
//    // already have one.
//    if (nil == locationManager)
//        locationManager = [[CLLocationManager alloc] init];
//    
////    CLLocationManager* locationManager = [[CLLocationManager alloc] init];
//    
////    locationManager.desiredAccuracy = kCLLocationAccuracyBesDs the  is kCLLocationAccuracyBestdefault
//    
//    // Set a movement threshold for new events.
//    locationManager.distanceFilter = 5;
//    
//    NSLog(@"locationManager.location: %@", locationManager.location);
//    
//    [locationManager startUpdatingLocation];
//}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    
    if(newLocation.horizontalAccuracy <= 10.0f) {
        [locationManager stopUpdatingLocation];
    }
}

//// Delegate method from the CLLocationManagerDelegate protocol.
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation
//{
//    // If it's a relatively recent event, turn off updates to save power
//    NSDate* eventDate = newLocation.timestamp;
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//    if (abs(howRecent) < 15.0)
//    {
//        NSLog(@"latitude %+.6f, longitude %+.6f\n",
//              newLocation.coordinate.latitude,
//              newLocation.coordinate.longitude);
//    }
//    // else skip the event and process the next one.
//}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if(error.code == kCLErrorDenied) {
        [locationManager stopUpdatingLocation];
    } else if(error.code == kCLErrorLocationUnknown) {
        // retry
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.delegate = self;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    
//    [self startStandardUpdates];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [locationManager stopUpdatingLocation];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get the destination buildingID from the server
    NSLog(@"building name: %@", self.buildingName);
    self.buildingID = [self getBuildingID:self.buildingName];
    NSLog(@"building id: %@", _buildingID);
    
    // Zoom to MSU's campus
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.015;
    span.longitudeDelta = 0.015;
    
    MKCoordinateRegion region;
    region.span = span;
    region.center = CLLocationCoordinate2DMake(42.723244, -84.482544);
    
    [_mapView setRegion:region animated:YES];
    [_mapView regionThatFits:region];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Retrieve users current location
    NSNumber* latitude  = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
    
    NSArray *path = [self getPathToDestination:_buildingID
                                  fromLatitude:latitude
                                  andLongitude:longitude];
    
    CLLocationCoordinate2D pathCoords[[path count]/2];
    NSLog(@"[path count]: %i", [path count]);
    
    for(int i=0; i<[path count]/2; i++)
        pathCoords[i] = CLLocationCoordinate2DMake([[path objectAtIndex:2*i+1] doubleValue], [[path objectAtIndex:2*i] doubleValue]);
    
    MKPolyline* pathPolyline = [MKPolyline polylineWithCoordinates:pathCoords count:[path count]/2];
    
    [_mapView addOverlay:pathPolyline];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
