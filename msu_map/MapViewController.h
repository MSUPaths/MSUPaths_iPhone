//
//  FirstViewController.h
//  msu_map
//
//  Created by Minh Pham on 10/11/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MapView.h"
#import "JSONParser.h"
#import "GoogleMaps.h"
#import "Building.h"
#import "Segment.h"
#import "SegmentHandler.h"

// Forward reference
@class Building;

// Control map view
@interface MapViewController : UIViewController
@property (strong) Building *destinationBuilding;

// update route using current data
- (void) updateRoute;

// draw route to a building
- (void) drawRouteFromCurrentLocationToBuilding: (Building*) building;
@end
