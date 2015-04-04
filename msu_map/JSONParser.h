//
//  JSONParser.h
//  msu_map
//
//  Created by Minh Pham on 11/10/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#include "SegmentHandler.h"

@interface JSONParser : NSObject

// Query database to get an array of lat, long
// Using old query system
// \return an array of lat, long
-(NSArray*)getPathToDestination:(NSString*)buildingID
                               :(NSNumber*) latitude
                               :(NSNumber*) longitude;

//  Query database to get segments data
// TO-DO server is not working right now
- (SegmentHandler*)getSegmentToDestination:(NSString*)buildingID
                    :(NSNumber*)latitude
                    :(NSNumber*)longitude;

- (SegmentHandler*)getSegmentFromLat: (double) fromLat
                                    : (double) fromLong
                                    : (double) toLat
                                    : (double) toLong;

// Query database to get a test segment
// Should not be used in actual application
- (SegmentHandler*) getTestSegment;
@end
