//
//  MapEdge.m
//  msu_map
//
//  Created by Pham Khac Minh on 4/23/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import "MapEdge.h"

@implementation MapEdge

// Please use this initialize to create a vertex object
// the line format supposed to be:
// E|4241|14669|SIDEWALK|155.636758775706|-84.4664727247662,42.725767184659,-84.4661352419568,42.7257463707261
- (id) init:(NSString *)line
{
    NSArray* lineArray = [line componentsSeparatedByString:@"|"];
    // Check if the first letter is E
    if (![line hasPrefix:@"E"]) NSLog(@"Wrong edge format:%@", line);
    
    _startVertexId = (int) [lineArray[1] integerValue];
    _endVertexId = (int) [lineArray[2] integerValue];
    NSString* edgeType = lineArray[3];
    double length = [lineArray[4] doubleValue];
    NSArray* edgeArray = [lineArray[5] componentsSeparatedByString:@","];

    self = [super initWithPath:edgeArray length:length name:@"No name" type:edgeType];
    return self;
}

// Reorienting the edge based on startVertexId and endVertexId
// \param startId id of the starting vertex
// \param endId id of the ending vertex
- (void) orientWithStart: (int) startId end: (int) endId {
    if (startId == _startVertexId && endId == _endVertexId) return; // already in right orientation
    else if (startId ==_endVertexId && endId == _startVertexId) {
        // need to reverse the points array
        [self reversePointsArray];
        _startVertexId = startId;
        _endVertexId = endId;
    }
    else NSLog(@"Wrong vertices:%d,%d to orient edge:%d,%d", startId, endId, _startVertexId, _endVertexId);
}

// Reverse the points array of lat long
- (void) reversePointsArray {
    NSMutableArray* newPointsArray = [[NSMutableArray alloc] initWithCapacity:[self.pointsArray count]];

    for(int i= (int)self.pointsArray.count; i>1; i -= 2) {
        [newPointsArray addObject:[self.pointsArray objectAtIndex:i-2]];
        [newPointsArray addObject:[self.pointsArray objectAtIndex:i-1]];
    }
    
    self.pointsArray = newPointsArray;
}

@end
