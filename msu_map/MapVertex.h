//
//  MapVertex.h
//  msu_map
//
//  Created by Pham Khac Minh on 4/23/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdjacentNeighbor;

// A vertex in map
@interface MapVertex : NSObject
@property (strong) NSString* name; // name of vertex
@property (strong) NSString* type; // type of vertex: node, sidewalk...
@property (readonly) int vertexId; // unique id of vertex
@property (readonly) double latitude; // latitude of vertex
@property (readonly) double longitude; // longitude of vertex

// supporting structure to path finding algorithm
@property (strong) NSArray* neighborArray; // array of neighbors to this vertex
@property double gScore; // the g-score of the vertex
@property double fScore; // the f-score of the vertex
@property AdjacentNeighbor* parent; // the previous edge

// Initialize using a string
- (id) init: (NSString*) line;

// Check if the vertex is close enough to a point
- (bool) isCloseToLatitude: (double) aLatitude Longitude: (double) aLongitude;

// Check if vertex is "smaller" than another vertex
- (bool) isSmallerThan: (MapVertex*) aVertex;

// Reset the score to default value
-(void) reset;

// check if vertex are the same
-(bool) isEqualTo: (MapVertex*) aVertex;

// update the parent of this vertex
-(void) updateParentByEdgeInx: (int) edgeInx;

@end

/*************************************************************************/
// The neighbor of a vertex -- used in path finding A* algorithm
@interface AdjacentNeighbor : NSObject
@property (readonly) int vertexInx; // the index of the neighbor vertex
@property (readonly) int edgeInx; // the index of the edge containing both of them
// Initialize with a string
-(id) initWithString: (NSString*) aString;

// Initialize with member variables
-(id) initWithVertexInx: (int) vertex EdgeInx: (int) edgeInx;

@end
