//
//  SegmentHelper.m
//  msu_map
//
//  Created by Pham Khac Minh on 3/5/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import "SegmentHelper.h"

@implementation SegmentHelper


// Angle big enough to consider 3 points being on the same line (in degree)
const float MidPointAngleThreshold = 15.0;

// Conversion constant from normal coordinate distance to feet
const double ConvertFromWGS84ToFeet = 271010.052;

// Distance Threshold for considering two points are the same (in feet)
const double DistanceThresHold = 15.0;

// Compute the bearing using three points
- (CGFloat) getBearingFrom:(CGPoint)startPoint intersect:(CGPoint)intersection to:(CGPoint)endPoint
{
    // compute bearing relative to start point
    CGPoint relativeStartPoint = CGPointMake(startPoint.x - intersection.x, startPoint.y - intersection.y);
    // check if the start point and intersection are the same
    if (relativeStartPoint.x == 0 && relativeStartPoint.y == 0) return 0.0;
    float bearingStart = atan2f(relativeStartPoint.y, relativeStartPoint.x);
    
    // Compute bearing relate to end point
    CGPoint relativeEndPoint = CGPointMake(endPoint.x - intersection.x, endPoint.y - intersection.y);
    // check if the start point and intersection are the same
    if (relativeEndPoint.x == 0 && relativeEndPoint.y == 0) return 0.0;
    float bearingEnd = atan2f(relativeEndPoint.y, relativeEndPoint.x);
    
    
    float bearingRadian = bearingEnd - bearingStart;
    float bearingDegrees = bearingRadian * 180 / M_PI;
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}

// Check to see if a point is between two points or not
// \return true if the mid point is in between two points
- (BOOL) checkMidPoint:(CGPoint) midPoint between:(CGPoint) aPoint and:(CGPoint) bPoint
{
    // check to see if midPoint is the same as aPoint or bPoint
    if ([self isTooClosePoint:midPoint point2:aPoint]) return true;
    if ([self isTooClosePoint:midPoint point2:bPoint]) return true;
    
    // Test angle between the points
    CGFloat bearing = [self getBearingFrom:aPoint intersect:midPoint to:bPoint];
    
    if (fabsf(bearing - 180) <= MidPointAngleThreshold) return true;
    
    // Thinking of the three points as a triangle
    // Compute the other two angles
    CGFloat bearingA = [self getBearingFrom:bPoint intersect:aPoint to:midPoint];
    CGFloat bearingB = [self getBearingFrom:aPoint intersect:bPoint to:midPoint];
    if (bearingA > 180) bearingA = 360 - bearingA;
    if (bearingB > 180) bearingB = 360 - bearingB;
    
    // Check if the angle at point a and b are both < 90 degree
    if (bearingA < 90 && bearingB < 90)
    {
        // Compute the sides of the triangles
        double sideA = [self computeDistanceWithLat:bPoint.x long:bPoint.y andLat:midPoint.x long:midPoint.y];
        double sideB = [self computeDistanceWithLat:aPoint.x long:aPoint.y andLat:midPoint.x long:midPoint.y];
        double sideMid = [self computeDistanceWithLat:bPoint.x long:bPoint.y andLat:aPoint.x long:aPoint.y];
        // The distance difference between the two sides and the mid side
        double distDifference = fabs(sideA + sideB - sideMid);
        if (distDifference < DistanceThresHold) return true;
    }
    
    return false;
}

// Compute distance between two pair of coordinate
// input are in double and in 'normal' coordinate: @-84.21312321
// \return the compute distance in feet
- (double) computeDistanceWithLat: (double const) lat1 long: (double const) long1
                              andLat: (double const) lat2 long: (double const) long2
{
    double dx = lat1 - lat2;
    double dy = long1 - long2;
    double dist = sqrt(dx*dx + dy*dy) * ConvertFromWGS84ToFeet;
    
    return dist;
}

// Compute distance from a path
// \param path an array of lat long coordinate
// \return approximate path in feet
- (double) computePathDistance: (NSArray*) path
{
    double dist = 0;
    if (path.count % 2 == 1)
    {
        NSLog(@"Error when computing path length: Invalid input length %lu", (unsigned long)path.count);
        return 0;
    }
    if (path.count <=2) {
        return 0;
    }
    double prevLat = [[path objectAtIndex:0] doubleValue];
    double prevLong = [[path objectAtIndex:1] doubleValue];
    double currLat = 0;
    double currLong = 0;
    for(int i=1; i<[path count]/2; i++)
    {
        currLat = [[path objectAtIndex:2*i] doubleValue];
        currLong = [[path objectAtIndex:2*i+1] doubleValue];
        dist += [self computeDistanceWithLat:prevLat long:prevLong andLat:currLat long:currLong];
        prevLat = currLat;
        prevLong = currLong;
    }
    return dist;
}

// Consider whether two WGS84 lat long pair are too close to each other or not
// \return true if the distance between the points are less than threshold
- (bool) isTooCloseLat: (double const) lat1 long: (double const) long1
                andLat: (double const) lat2 long: (double const) long2
{
    double dist = [self computeDistanceWithLat:lat1 long:long1 andLat:lat2 long:long2];
    return dist <= DistanceThresHold;
}

// Consider whether two WGS84 points are too close to each other or not
// \return true if the distance between the points are less than threshold
- (bool) isTooClosePoint: (CGPoint) aPoint point2: (CGPoint) bPoint
{
    double dist = [self computeDistanceWithLat:aPoint.x long:aPoint.y andLat:bPoint.x long:bPoint.y];
    return dist <= DistanceThresHold;
}

@end
