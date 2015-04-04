//
//  SegmentHelper.h
//  msu_map
//
//  Created by Pham Khac Minh on 3/5/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>


// Auxilary function to help segment classes
@interface SegmentHelper : NSObject

// Compute the bearing using three points
// \return angle between 0 and 360
- (CGFloat) getBearingFrom:(CGPoint)startPoint intersect:(CGPoint)intersection to:(CGPoint)endPoint;

// Check to see if a point is between two points or not
// \return true if the mid point is in between two points
- (BOOL) checkMidPoint:(CGPoint) midPoint between:(CGPoint) aPoint and:(CGPoint) bPoint;

// Compute distance between two pair of coordinate
// input are in double and in 'normal' coordinate: @-84.21312321
// Good for about 0.2 feet
// \return the compute distance in feet
- (double) computeDistanceWithLat: (double const) lat1 long: (double const) long1
                              andLat: (double const) lat2 long:(double const) long2;

// Compute distance from a path
// \param path an array of lat long coordinate
// \return approximate path in feet
- (double) computePathDistance: (NSArray*) path;


// Consider whether two WGS84 lat long pair are too close to each other or not
// \return true if the distance between the points are less than threshold
- (bool) isTooCloseLat: (double const) lat1 long: (double const) long1
                andLat: (double const) lat2 long: (double const) long2;

// Consider whether two WGS84 points are too close to each other or not
// \return true if the distance between the points are less than threshold
- (bool) isTooClosePoint: (CGPoint) aPoint point2: (CGPoint) bPoint;

@end
