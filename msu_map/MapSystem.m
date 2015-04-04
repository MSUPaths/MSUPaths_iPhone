//
//  MapSystem.m
//  msu_map
//
//  Created by Pham Khac Minh on 4/23/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import "MapSystem.h"

#include "AStarPathFinder.h"
#include "SegmentHelper.h"

// file name should not contain the extension (just the way xcode work)
// Map sytem list file
// the default extension is txt
#define MapSystemFile @"map_system_with_adjacency_list"

@implementation MapSystem {
    NSArray* _vertexArray; // Array contains all vertices
    NSArray* _edgeArray; // Array contains all edges
    AStarPathFinder* _pathFinder; // the path finder engine
    SegmentHelper* segHelper; // for computing distance
}

// Initialize map system based on text file
- (id) init
{
    // Get the path, then load the content
    NSString *path = [[NSBundle mainBundle] pathForResource:MapSystemFile ofType:@"txt"];
    if (path == nil) NSLog(@"File %@ not found", MapSystemFile);
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\n"];
    
    NSMutableArray* tempVertexArray = [[NSMutableArray alloc] init]; // empty vertices list
    NSMutableArray* tempEdgeArray = [[NSMutableArray alloc] init]; // empty edges list
    
    for (NSString* line in lines) {
        if ([line length] < 5) break; // guard a against empty line
        
        // Check for vertex prefix
        if ([line hasPrefix:@"V"]) {
            MapVertex *tempVertex = [[MapVertex alloc] init:line];
            [tempVertexArray addObject:tempVertex];
        }
        else if ([line hasPrefix:@"E"]) {
            // edge prefix
            MapEdge *tempEdge = [[MapEdge alloc] init:line];
            [tempEdgeArray addObject:tempEdge];
        }
    }
    
    _vertexArray = tempVertexArray;
    _edgeArray = tempEdgeArray;
    _pathFinder = [[AStarPathFinder alloc] initWithGraph:self];
    segHelper = [[SegmentHelper alloc] init];
    
    tempVertexArray = tempEdgeArray = nil;
    return self;
}

// Get a vertex by its index in the array
- (MapVertex*) getVertexByIndex: (int) i {
    if (i < _vertexArray.count) return [_vertexArray objectAtIndex:i];
    else NSLog(@"Index for vertex array too big: %d", i);
    return nil;
}

// Get an edge by its index in the array
- (MapEdge*) getEdgeByIndex: (int) i {
    if (i < _edgeArray.count) return [_edgeArray objectAtIndex:i];
    else NSLog(@"Index for edge array too big: %d", i);
    return nil;
}

// reset all vertices to original state
// Call reset on all vertices
- (void) resetVertices {
    for (MapVertex* vertex in _vertexArray) [vertex reset];
}

// Find path and return a segment handler object
// \param latitude the current location latitude
// \param longitude the current location longitude
// \param vertexInx the index of the vertex to go to
- (SegmentHandler*) findPathFromLatitude: (double) latitude
                               longitude: (double) longitude
                             toVertexInx: (int) vertexInx {
    MapVertex* startVertex = [self getVertexByIndex:[self vertexInxCloseToLat:latitude longitude:longitude]];
    MapVertex* endVertex = [self getVertexByIndex:vertexInx];
    
    NSArray* edgeArray = [_pathFinder findPathFromVertex:startVertex to:endVertex];
    return [[SegmentHandler alloc] initWithEdgeArrray:edgeArray];
}

// Find the index of the node that is closest to a given coordinate
- (int) vertexInxCloseToLat: (double) latitude longitude: (double) longitude {
    double minDistance = DBL_MAX; // minimal distance vertex
    double currDistance = 0.0; // the distance from current vertex to the pair of coordinate
    MapVertex* currVertex = nil; // the current vertex
    int vertexInx = 0; // index of the minimal distance vertex
    
    for (int i=0; i<_vertexArray.count; i++) {
        currVertex = [_vertexArray objectAtIndex:i];
        currDistance = [segHelper computeDistanceWithLat:[currVertex latitude] long:[currVertex longitude]
                                                  andLat:latitude long:longitude];
        
        if (currDistance < minDistance) {
            minDistance = currDistance;
            vertexInx = i;
        }
    }
    
    currVertex = [self getVertexByIndex:vertexInx];
    return vertexInx;
}

@end
