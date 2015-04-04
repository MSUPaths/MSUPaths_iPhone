//
//  DirectionGiver.m
//  msu_map
//
//  Created by Pham Khac Minh on 2/18/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import "DirectionGiver.h"
#import "Segment.h"
#import "SegmentHandler.h"
#import "SegmentHelper.h"

@implementation DirectionGiver {
    SegmentHandler* segHandler;
    SegmentHelper* segHelper;
    int currSegInx; // index of segment the current location is on right now
    int currPointInx; // index in the current segment of the current location
    double prevDistance; // Previous distance to intersection -- used to restrict number of message update
}

@synthesize directionString;
@synthesize currLat;
@synthesize currLong;

// constants
// format string used when the user is far from the intersection
static NSString* FarFormatString= @"In %d feet, head toward %@ o'clock";

// format string used when the user is close to the intersection
static NSString* NowFormatString= @"Head toward %@ o'clock now";

// format string used when the user is in the last segment
static NSString* FarFinalFormatString= @"Reach your destination in %d feet";

// format string used when the user reach the final destination
static NSString* EndPathString= @"You have reached your destination";

// String used when the user is on a wrong path
static NSString* WrongPathString= @"You seem to be on the wrong path";

// Distance consider to be "close" to the intersection
const double CloseDistanceThreshold = 40.0;

// Distance consider to be right next to the intersection
const double NowDistanceThreshold = 15.0;


-(id) initWithSegHandler:(SegmentHandler *)aSegHandler
{
    segHandler = aSegHandler;
    segHelper = [SegmentHelper alloc];
    currSegInx = (int) [[segHandler getAllSegments] count] - 1;
    currPointInx = (int) [[[[segHandler getAllSegments] lastObject] getPath] count] - 3;
    directionString = @"Direction not ready";
    currLat = 0;
    currLong = 0;
    prevDistance = -1.0;
    
    return self;
}

// Compute bearing and change it to clock format
- (NSNumber*) convertBearingToClock: (CGFloat) bearingDegrees
{
    // intersection is the same as start or end point
    if (bearingDegrees == NZERO) return NULL;
    
    int clock = (int) (bearingDegrees + 15) / 30;
    clock = 12 - (clock + 6) % 12;
    return [NSNumber numberWithInt:clock];
}

// Decide to update or not
-(UpdateState) updateLocationLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude
{
    currLat = latitude;
    currLong = longitude;
    
    int newSegInx = 0;
    int newPointInx = 0;
    
    // looping throught the entire segment array
    // TODO: improve performance by looking at only a subset of segments
    for (int i=0; i<[segHandler getAllSegments].count; i++)
    {
        newPointInx = [[[segHandler getAllSegments] objectAtIndex:i] findIndexOfLat:latitude long:longitude];
        if (newPointInx >= 0)
        {
            // if found the segment with current location
            newSegInx = i;
            break;
        }
    }
    
    // set flag to know that we changed segments
    if (newSegInx != currSegInx) prevDistance = -1.0;
    
    if (newPointInx > 0)
    {
        // found something
        currPointInx = newPointInx;
        currSegInx = newSegInx;
        return [self updateDirectionWithSegment];
    }
    else {
        // did not find the point
        directionString = WrongPathString;
        return DeviatedFromPath;
    }
    
    return KeepStatusBar;
}

// index of segment the current location is on right now
- (int) getCurrSegInx
{
    return currSegInx;
}

// index in the current segment of the current location
- (int) getCurrPointInx
{
    return currPointInx;
}

// Check if the direction giver already get update once for the current location yet or not
- (bool) hasCurrentLocation
{
    return currLat != 0 && currLong != 0;
}

// update direction string based on current Segment
- (UpdateState) updateDirectionWithSegment
{
    assert(currPointInx >= 1);
    Segment* currSeg = [[segHandler getAllSegments] objectAtIndex:currSegInx];
    
    // Get bearing to next segment
    NSNumber* bearing = [self convertBearingToClock:[currSeg bearingToNextSegment]];
    
    // Compute current length
    double segLength = [currSeg getLengthTillIndex:currPointInx];
    double endLat = [[[currSeg getPath] objectAtIndex:currPointInx] doubleValue];
    double endLong = [[[currSeg getPath] objectAtIndex:currPointInx - 1] doubleValue];
    segLength += [segHelper computeDistanceWithLat:endLat long:endLong
                                            andLat:[currLat doubleValue] long:[currLong doubleValue]];
    
    UpdateState flag = UpdateStatusBar;
    
    if (currSegInx == 0) {
        // we are at the last segment
        if (prevDistance < 0) {
            // We are in a new segment
            directionString = [[NSString alloc] initWithFormat:FarFinalFormatString, (int)segLength];
        }
        else if (prevDistance >= CloseDistanceThreshold && segLength < CloseDistanceThreshold) {
            // we transit from far to close distance
            directionString = [[NSString alloc] initWithFormat:FarFinalFormatString, (int)CloseDistanceThreshold];
        }
        else if (segLength < NowDistanceThreshold) {
            // we arrive at the destination
            directionString = EndPathString;
            flag = EndPath;
        }
        else flag = KeepStatusBar;
    }
    else if (prevDistance < 0) {
        // We are in a new segment
        directionString = [[NSString alloc] initWithFormat:FarFormatString, (int)segLength, bearing];
    }
    else if (prevDistance >= CloseDistanceThreshold && segLength < CloseDistanceThreshold) {
        // we transit from far to close distance
        directionString = [[NSString alloc] initWithFormat:FarFormatString, (int)CloseDistanceThreshold, bearing];
    }
    else if (prevDistance >= NowDistanceThreshold && segLength < NowDistanceThreshold) {
        // we transit from close to now distance
        directionString = [[NSString alloc] initWithFormat:NowFormatString, bearing];
    }
    else flag = KeepStatusBar; // do nothing == don't update the direction string
    prevDistance = segLength;
    
    return flag;
}

@end
