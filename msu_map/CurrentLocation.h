//
//  CurrentLocation.h
//  msu_map
//
//  Created by Minh Pham on 11/9/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class MapView;

@interface CurrentLocation : NSObject<CLLocationManagerDelegate>

// Start location service
- (void) Start;
// Stop location service
- (void) Stop;

// Print the device location in a nice format
- (NSString *) deviceLocation;

- (NSNumber *) latitude;
- (NSNumber *) longitude;
- (CLLocationCoordinate2D) location;

// Check if you can retrieve the current user location
- (BOOL) isWorking;

@end
