//
//  DirectionGiver.h
//  msu_map
//
//  Created by Pham Khac Minh on 2/18/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SegmentHandler;

// Give direction base on current location
// update the direction and segHandler segmentArray if necessary
@interface DirectionGiver : NSObject

@property (strong) NSString* directionString;
@property (strong) NSNumber* currLat;
@property (strong) NSNumber* currLong;

typedef NS_ENUM(NSInteger, UpdateState) {
    UpdateStatusBar, // should update the status bar with new direction
    KeepStatusBar, // do not update status bar
    DeviatedFromPath, // significant deviation from original path, need to query the server again
    EndPath // reach the destination
};

// init with a seg handler object
-(id) initWithSegHandler: (SegmentHandler*) aSegHandler;

// Decide whether to update direction giver or not
-(UpdateState) updateLocationLatitude: (NSNumber*) latitude longitude: (NSNumber*) longitude;

// Check if the direction giver already get update once for the current location yet or not
- (bool) hasCurrentLocation;

- (int) getCurrSegInx; // index of segment the current location is on right now
- (int) getCurrPointInx; // index in the current segment of the current location

@end
