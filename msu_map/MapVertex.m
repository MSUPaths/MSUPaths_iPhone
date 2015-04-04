//
//  MapVertex.m
//  msu_map
//
//  Created by Pham Khac Minh on 4/23/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import "MapVertex.h"

#import <float.h>
#include "SegmentHelper.h"

@implementation MapVertex

// Please use this initialize to create a vertex object
// the line format supposed to be:
// V|6300|NODE|N SHAW LN|-84.4809188722733|42.7259821850764|8904,9563;2814,9907
// identifier|id|type|name|lat|long|adjacency list
- (id) init:(NSString *)line
{
    NSArray* lineArray = [line componentsSeparatedByString:@"|"];
    // Check if the first letter is V
    if (![line hasPrefix:@"V"]) NSLog(@"Wrong vertex format:%@", line);
    
    [self reset];
    _vertexId = (int) [lineArray[1] integerValue];
    _type = lineArray[2];
    _name = lineArray[3];
    _longitude = [lineArray[4] doubleValue];
    _latitude = [lineArray[5] doubleValue];
    
    if (lineArray.count < 7) NSLog(@"Vertex don't have adjacency list");
    else {
        NSArray* stringArray = [lineArray[6] componentsSeparatedByString:@";"];
        NSMutableArray* neighborArray = [[NSMutableArray alloc] init];
        for (NSString* neighbor in stringArray) {
            [neighborArray addObject:[[AdjacentNeighbor alloc] initWithString:neighbor]];
        }
        _neighborArray = neighborArray;
    }
    return self;
}

// Check if the vertex is close enough to a point
// \param aLatitude lat of the point
// \param aLongitude long of the point
// \return true if the distance from point to vertex is within certain threshold
- (bool) isCloseToLatitude: (double) aLatitude Longitude: (double) aLongitude {
    return [[SegmentHelper alloc] isTooCloseLat:_latitude long:_longitude andLat:aLatitude long:aLongitude];
}

// Check if vertex is "smaller" than another vertex
// \param aVertex pointer to another vertex to compare
// \return true if the vertex is smaller
- (bool) isSmallerThan: (MapVertex*) aVertex {
    if (aVertex == nil) return true;
    return [self fScore] < [aVertex fScore];
}

// Reset the score to default value
-(void) reset {
    _gScore = DBL_MAX;
    _fScore = DBL_MAX;
    _parent = nil;
}

// check if vertex are the same
-(bool) isEqualTo: (MapVertex*) aVertex {
    return _vertexId == [aVertex vertexId];
}

// update the parent of this vertex
// \param edgeInx the index of the edge connecting this vertex to the "parent" vertex
-(void) updateParentByEdgeInx: (int) edgeInx {
    for (AdjacentNeighbor* neighbor in _neighborArray)
        if (neighbor.edgeInx == edgeInx) {
            _parent = neighbor;
            break;
        }
}

@end

/*************************************************************************/
// Adjacent neighbor class
@implementation AdjacentNeighbor

// Initalize with string
// String should have format:
// 8904,9563
// vertex index, edge index
-(id) initWithString:(NSString *)aString {
    _vertexInx = (int) [[[aString componentsSeparatedByString:@","] firstObject] integerValue];
    _edgeInx = (int) [[[aString componentsSeparatedByString:@","] lastObject] integerValue];
    return self;
}

// Initialize with member variables
-(id) initWithVertexInx: (int) vertex EdgeInx: (int) edgeInx {
    _vertexInx = vertex;
    _edgeInx = edgeInx;
    return self;
}

@end
