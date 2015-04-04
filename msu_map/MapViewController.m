;//
//  FirstViewController.m
//  msu_map
//
//  Created by Minh Pham on 10/11/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "MapViewController.h"
#import "DirectionGiver.h"
#import "MapSystem.h"

// Distant consider as big enough to separate two point (use to
// compare end point of path with current location)
const double DistanceThreshold = 0.0005;

@interface MapViewController ()

@end

@implementation MapViewController{
    MapView *mapView;
    JSONParser *parse;
    CurrentLocation *currLoc;
    GoogleMaps *googleMaps;
    SegmentHandler* segHandler;

    IBOutlet UIView *mapViewUI;
    __weak IBOutlet UITextView *statusBar;
}
@synthesize destinationBuilding;

// Constructor
- (void) viewDidLoad
{
    currLoc = [[CurrentLocation alloc] init];
    parse = [JSONParser alloc];
    googleMaps = [GoogleMaps alloc];
    mapView = [[MapView alloc] init:self withView:mapViewUI];
    segHandler = nil;

    statusBar.text = @"starting...";
    [self drawRoute];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //buildingID = @"0022";
}

// Draw path between current location and building
// \pre destinationBuilding must not be nil
- (void) drawRoute
{
    if (![currLoc isWorking])
    {
        [self updateStatus:@"Cannot find current location"];
        //return;
    }
    
    if (destinationBuilding != nil)
    {
        [mapView clearAll];
        
        NSString* buildingID = [destinationBuilding ID];
        
        [currLoc Start];
        
        // Retrieve users current location
        NSNumber* longitude  = @42.729944; // used for testing
        NSNumber* latitude = @(-84.473534); // used for testing
        //latitude = [currLoc latitude];
        //longitude = [currLoc longitude];
        //NSLog(@"Current location: %@", [currLoc deviceLocation]);
        NSLog(@"Destination location: latitude: %@, longitude: %@", [destinationBuilding latitude], [destinationBuilding longitude]);
        
        [mapView addAnnotation: [destinationBuilding latitude] : [destinationBuilding longitude] : [destinationBuilding commonName]];
        [self updateStatus:@"Retrieving path from server ..."];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self updateSegmentFromMapSystem:buildingID lat:latitude long:longitude]; // 1
            dispatch_async(dispatch_get_main_queue(), ^{
                if (segHandler)
                {
                    [self updateStatus:@"Retrieved data successfully"];
                    [self addColorfulSegmentToMap];
                }
                else
                {
                    [self updateStatus:@"Cannot connect to server" ];
                }
            
            });
        });
        
    }
    else {
        NSLog(@"destinationBuilding has not been initialize");
        [self updateStatus:@"Please choose a destination from the list"];
    }
}

// Draw direction from current location to end path using Apple map kit
-(NSArray*) getPathFromCurrentLocationToEndPathUsingGoogleMap: (CLLocationCoordinate2D) endPath
{
    NSArray* path = [googleMaps getRoutesFrom:endPath to:[currLoc location]];
    return path;
}


// Draw route from current location to building
-(void) drawRouteFromCurrentLocationToBuilding:(Building *)building
{
    destinationBuilding = building;
    [self drawRoute];
}


//  Destructor
- (void) dealloc
{
    [currLoc Stop];
    mapView = nil;
    parse = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [currLoc Stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Get path array from server
- (void) updateSegmentFromServer: (NSString*) buildingID lat: (NSNumber*) latitude long: (NSNumber*)longitude
{
    segHandler = [parse getSegmentFromLat:-84.480924 :42.7250467 :[latitude doubleValue] :[longitude doubleValue]];
    //MapSystem* mapSys = [[MapSystem alloc] init];
    //segHandler = [mapSys findPathFromLatitude:[latitude doubleValue] longitude:[longitude doubleValue] toVertexInx:10];
}

// Get path array from map system
- (void) updateSegmentFromMapSystem: (NSString*) buildingID lat: (NSNumber*) latitude long: (NSNumber*)longitude
{
    segHandler = [parse getSegmentFromLat:-84.480924 :42.7250467 :[latitude doubleValue] :[longitude doubleValue]];
    int x = 0;
    //MapSystem* mapSys = [[MapSystem alloc] init];
    //segHandler = [mapSys findPathFromLatitude:[latitude doubleValue] longitude:[longitude doubleValue] toVertexInx:10];
}

// Get path array from server
- (NSArray*) getPath: (NSString*) buildingID lat: (NSNumber*) latitude long: (NSNumber*)longitude
{
    // Retrieve the path array frrom server using JSON parser
    /*
    SegmentHandler *segHandler = [parse getSegmentToDestination:buildingID
                                                               :latitude
                                                               :longitude];
     */
    segHandler = [parse getTestSegment];
    
    NSArray* path = nil;
    
    if (segHandler && [segHandler getPathWithoutCurrentLocation])
    {
        [self addColorfulSegmentToMap];
        path = nil;
    }
    else
    {
        path = [parse getPathToDestination:buildingID :latitude :longitude];
    }
    if (path != nil)
    {
        // Check the path end point (relate to the current location
        CLLocationCoordinate2D endPath = CLLocationCoordinate2DMake([[path objectAtIndex:1] doubleValue], [[path objectAtIndex:0] doubleValue]);
        
        // Calculate the distance between the endpoint and current location
        double dx = (endPath.latitude - [latitude doubleValue]);
        double dy = (endPath.longitude - [longitude doubleValue]);
        double dist = sqrt(dx*dx + dy*dy);
        
        if (dist >= DistanceThreshold)
        {
            // if the distance is bigger than the threshold
            NSLog(@"End point: lat: %f, long: %f", endPath.latitude, endPath.longitude);
            //NSArray* googlePath = [self getPathFromCurrentLocationToEndPathUsingGoogleMap:endPath];
        }
        
        return path;
    }
    else
    {
        NSLog(@"Query from %@,%@ to %@ unsuccessful", latitude, longitude, buildingID);
        NSLog(@"Cannot connect to retrieve path from server");
        return NULL;
    }
}

// Add rainbow color segment to map
// only for debugging and giggling purpose only
- (void) addColorfulSegmentToMap
{
    NSArray* segArray = [segHandler getAllSegments];
    NSArray* colorArray = [NSArray arrayWithObjects: [UIColor redColor], [UIColor orangeColor], [UIColor yellowColor],
                           [UIColor greenColor], [UIColor blueColor], [UIColor blackColor], nil];
    for (int i=0; i<[segArray count]; i++)
    {
        [mapView addOverlayArray: [[segArray objectAtIndex:i] getPath] color:[colorArray objectAtIndex:(i%6)]];
    }
}

- (void) addPathToMap: (NSArray*) path
{
    [mapView addOverlayArray:path];
}

- (void) updateStatus: (NSString*) text
{
    statusBar.text = text;
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


// Update route using current location
- (void) updateRoute
{
    DirectionGiver* dirGiver = [segHandler dirGiver];
    UpdateState flag = [dirGiver updateLocationLatitude:[currLoc latitude] longitude:[currLoc longitude]];
    NSArray* path = nil;
    
    switch (flag) {
        case UpdateStatusBar:
            [self updateStatus:[dirGiver directionString]];
        case KeepStatusBar:
            path = [segHandler getPathWithoutCurrentLocation];
            [self addPathToMap:path];
            break;
            
        case DeviatedFromPath:
        case EndPath:
        default:
            [self updateStatus:[dirGiver directionString]];
            break;
    }
}

@end
