//
//  MapSystem.h
//  msu_map
//
//  Created by Pham Khac Minh on 4/23/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "MapEdge.h"
#include "MapVertex.h"
#include "SegmentHandler.h"

// Map system based on text file
// contains vertices and edges

@interface MapSystem : NSObject

// initialize the map system based on text file
- (id) init;

// Get a vertex by its index in the array
- (MapVertex*) getVertexByIndex: (int) i;

// Get an edge by its index in the array
- (MapEdge*) getEdgeByIndex: (int) i;

// reset all vertices to original state
- (void) resetVertices;

// Find path and return a segment handler object
- (SegmentHandler*) findPathFromLatitude: (double) latitude
                             longitude: (double) longitude
                                toVertexInx: (int) vertexInx;

// Find the index of the node that is closest to a given coordinate
- (int) vertexInxCloseToLat: (double) latitude longitude: (double) longitude;

@end
