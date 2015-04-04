//
//  Segment.h
//  msu_map
//
//  Created by Pham Khac Minh on 10/5/13.
//  Copyright (c) 2013 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

// Represent a segment with points, length, type, name and angle to next segment
@interface Segment : NSObject

@property (strong) NSString* name;
@property (strong) NSString* type;
@property (readonly) double pathLength;
@property CGFloat bearingToNextSegment;
@property NSArray* pointsArray;

// init with properly format json object
- (id) initWithJSON: (NSDictionary*) json;

// init with all properties
- (id) initWithPath: (NSArray*) aPath
             length: (double) aLength
               name: (NSString*) aName
               type: (NSString*) aType;

// Try to merge two segments together
// \return a new segment from merging, nil if not mergeable
-(Segment*) mergeWithSegment: (Segment*) aSeg;

// Compute the bearing to switch from this segment to another segment
- (CGFloat) getBearingToSegment: (Segment*)toSeg;

// Update bearingToNextSegment for the new segment
- (void) updateBearingFromSegment: (Segment*)toSeg;

// Determine whether a point is on the segment
// \return index of the pointsArray found where the point is closest
// 0 if too close to the first end point
// negative if not found
- (int) findIndexOfLat: (NSNumber*) latitude
                  long: (NSNumber*) longitude;

// Return an array of lat long coordinates
- (NSArray*) getPath;

// Return number of points in the path
- (int) pathCount;

// Return an array of lat long coordinates till an index (include the index as well)
- (NSArray*) getPathTillIndex: (int) i;

// Return the total path length
- (double) getLength;

// Return the path length till index
- (double) getLengthTillIndex: (int) i;

@end
