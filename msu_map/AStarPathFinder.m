//
//  AStarPathFinder.m
//  msu_map
//
//  Created by Pham Khac Minh on 4/24/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import "AStarPathFinder.h"

#include "SegmentHelper.h"
#include "MinHeap.h"

// The heuristic factor to be used to damp the heuristic score
const double HeuristicFactor = 1.5;

// Using A* algorithm to find the path
@implementation AStarPathFinder {
    SegmentHelper* segHelper;
}

// initialize with a map system
-(id) initWithGraph:(MapSystem *)mapSystem {
    _graph = mapSystem;
    segHelper = [SegmentHelper alloc];
    return self;
}

// heuristic method to get a score between two vertices
// \param aVertex one map vertex
// \param bVertex the second map vertex
// \return the approximate distance between the two vertex
-(double) heuristicScore: (MapVertex*) aVertex and: (MapVertex*) bVertex {
    return HeuristicFactor * [segHelper computeDistanceWithLat:[aVertex latitude] long:[aVertex longitude]
                                      andLat:[bVertex latitude] long:[bVertex longitude]];
}

// find path from one vertex to another one
// implement A* algorithm from wikipedia
// \param startVertex the starting vertex
// \param endVertex the ending vertex
// \return array of edges
-(NSArray*) findPathFromVertex: (MapVertex*) startVertex to: (MapVertex*) endVertex
{
    NSLog(@"Computing path from node %d to node %d", [startVertex vertexId], [endVertex vertexId]);
    
    [_graph resetVertices];
    
    [startVertex setGScore:0.0];
    [startVertex setFScore:[self heuristicScore:startVertex and:endVertex]];
    
    MinHeap* openList   = [[MinHeap alloc] init];
    [openList addObject:startVertex];
    
    NSMutableSet* closedList = [[NSMutableSet alloc] init];
    
    MapVertex* current = nil;
    
    while (true) {
        if ([openList count] == 0) return nil; // cannot find the path
        current = [openList extractMin];
        if ([endVertex isEqualTo:current]) break;
        [closedList addObject: current];
        
        for (AdjacentNeighbor* adNeighbor in [current neighborArray]) {
            MapVertex* neighbor = [_graph getVertexByIndex:[adNeighbor vertexInx]];
            if ([closedList containsObject:neighbor]) continue;
            
            MapEdge* edge = [_graph getEdgeByIndex:[adNeighbor edgeInx]];
            double tentativeGscore = current.gScore + [edge pathLength];
            
            bool flag = ![openList containsObject:neighbor];
            if (flag || tentativeGscore < neighbor.gScore) {
                [neighbor updateParentByEdgeInx:[adNeighbor edgeInx]];
                neighbor.gScore = tentativeGscore;
                neighbor.fScore = tentativeGscore + [self heuristicScore:neighbor and:endVertex];
                if (flag) [openList addObject:neighbor];
            }
            
        }

    }
    
    return [self reconstructPath:current];
}

// Reconstruct the path
// \param endVertex the ending vertex
// return an array of edges
- (NSArray*) reconstructPath: (MapVertex*) endVertex {
    NSMutableArray *path = [[NSMutableArray alloc] init];
    MapEdge* currEdge = nil;
    MapVertex* nextVertex = nil;
    
    while (endVertex.parent != nil) {
        currEdge = [_graph getEdgeByIndex:[endVertex.parent edgeInx]];
        nextVertex =[_graph getVertexByIndex:[endVertex.parent vertexInx]];
        [currEdge orientWithStart:[nextVertex vertexId] end:[endVertex vertexId]];
        [path insertObject:currEdge atIndex:0];
        endVertex = nextVertex;
    }
    
    return path;
}
@end
