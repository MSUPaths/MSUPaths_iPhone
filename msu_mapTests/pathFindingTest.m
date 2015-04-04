//
//  pathFindingTest.m
//  msu_map
//
//  Created by Pham Khac Minh on 4/23/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MapSystem.h"
#import "MapVertex.h"
#import "MinHeap.h"
#import "AStarPathFinder.h"

@interface pathFindingTest : XCTestCase {
    MapSystem* mapSystem;
}

@end

@implementation pathFindingTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    mapSystem = [[MapSystem alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testVertex
{
    MapVertex* aVertex = [mapSystem getVertexByIndex:0];
    if ([aVertex vertexId] != 6300)XCTFail(@"Wrong vertex");
    if (![aVertex isCloseToLatitude:42.72598 Longitude:-84.48091]) XCTFail(@"Wrong coordinates of vertex");
    if ([aVertex neighborArray].count == 0) XCTFail(@"Vertex has no adjacency list");
}

- (void)testEdge
{
    MapEdge* aEdge = [mapSystem getEdgeByIndex:0];
    if ([aEdge startVertexId] != 8790)XCTFail(@"Wrong edge");
}

- (void)testMinHeap
{
    MinHeap* minHeap = [[MinHeap alloc] init];
    for (int i=0; i<20; i++) {
        [minHeap addObject:[mapSystem getVertexByIndex:i]];
    }
    MapVertex* aVertex = [minHeap extractMin];
    if ([aVertex vertexId] != 6300) XCTFail(@"Wrong vertexId in extract min:%d", [aVertex vertexId]);
    aVertex = [minHeap extractMin];
    if ([aVertex vertexId] != 6299) XCTFail(@"Wrong vertexId in extract min:%d", [aVertex vertexId]);
}

- (void) testPathFinding
{
    AStarPathFinder* pathFinder = [[AStarPathFinder alloc] initWithGraph:mapSystem];
    MapVertex* aVertex = [mapSystem getVertexByIndex:0];
    MapVertex* bVertex = [mapSystem getVertexByIndex:1];
    NSArray* edges = [pathFinder findPathFromVertex:aVertex to:bVertex];
    
    if (edges == nil || edges.count == 0) XCTFail(@"Can't find path");
    if (edges.count != 3) XCTFail(@"Wrong path number: %lu", (unsigned long)edges.count);
}
@end
