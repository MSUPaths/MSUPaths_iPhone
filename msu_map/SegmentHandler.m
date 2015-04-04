//
//  SegmentHandler.m
//  msu_map
//
//  Created by Pham Khac Minh on 10/5/13.
//  Copyright (c) 2013 Minh Pham. All rights reserved.
//

#import "SegmentHandler.h"

#include "MapEdge.h"

@implementation SegmentHandler { 
    NSArray* segmentArray; // array contains all segments
    NSArray* pathArray; // array contains all path
}

@synthesize pathLength;
@synthesize dirGiver;

- (id) initWithContent:(NSDictionary*)content
{
    NSArray* geometry = [content objectForKey:@"GEOMETRY"];
    NSMutableArray* segments = [[NSMutableArray alloc] initWithCapacity:[geometry count]];
    for(int i=0; i<[geometry count]; i++)
    {
        Segment* tempSeg = [[Segment alloc] initWithJSON:[geometry objectAtIndex:i]];
        [segments addObject:tempSeg];
    }
    segmentArray = segments;
    pathLength = [content objectForKey:@"GEOM_LENGTH"];
    
    [self setUp];
    return self;
}

- (id) initWithPaths:(NSArray*)paths
{
    NSMutableArray* segments = [[NSMutableArray alloc] initWithCapacity:[paths count]];
    double tempPathLength = 0.0;
    for(int i=0; i<[paths count]; i++)
    {
        NSMutableArray* pointsArray = [[NSMutableArray alloc] init];
        double length = 0.0;
        NSArray* path = paths[i];
        for (int j=0; j< [path count]; j++) {
            NSArray* point = [path objectAtIndex:j];
            
            [pointsArray addObject:point[0]];
            [pointsArray addObject:point[1]];
            length = [point[2] doubleValue];
        }
        NSString* segName = [NSString stringWithFormat:@"path %d", i];
        Segment* tempSeg = [[Segment alloc] initWithPath:pointsArray length:length name:segName type:@"none"];
        [segments addObject:tempSeg];
        tempPathLength += length;
    }
    segmentArray = segments;
    pathLength = [NSNumber numberWithDouble:tempPathLength];
    
    [self setUp];
    return self;
}

// Constructor with edges array
// \param edgeArray an array with MapEdge elements
- (id) initWithEdgeArrray: (NSArray*) edgeArray {
    segmentArray = edgeArray;
    pathLength = [[NSNumber alloc] initWithDouble:0.0];
    
    [self setUp];
    return self;
}

// Do set up after initialization
-(void) setUp {
    [self trimSegment];
    [self computeSegmentsBearing];
    dirGiver = [[DirectionGiver alloc] initWithSegHandler:self];
    
    NSMutableArray* path = [[NSMutableArray alloc] init];
    for(int i=0; i < [segmentArray count]; i++)
    {
        [path addObjectsFromArray:[[segmentArray objectAtIndex:i] getPath]];
    }
    pathArray = path;
}

// Get current path from segments and current location
- (NSArray*) getPathWithoutCurrentLocation
{
    int currSegInx = [dirGiver getCurrSegInx];
    int currPointInx = [dirGiver getCurrPointInx];
    int pathInx = 0; // index of last point in path array
    
    for(int i=0; i < currSegInx; i++)
    {
        pathInx += [[segmentArray objectAtIndex:i] pathCount];
    }
    
    if (currSegInx >= 0) {
        pathInx += currPointInx;
    }
    
    assert(pathInx % 2 == 1);
    if (pathInx > pathArray.count-3) {
        NSLog(@"I skewed up: Path index too big: %d", pathInx);
        pathInx = (int)pathArray.count-3;
    }
    return [pathArray subarrayWithRange:NSMakeRange(0, pathInx+3)];
}

// Return the segment array
-(NSArray*) getAllSegments
{
    return segmentArray;
}

// Number of segment
-(NSUInteger*) count
{
    return [segmentArray count];
}

// Get the length of the path till current location
// length is in feet
- (double) getCurrentPathLength;
{
    int currSegInx = [dirGiver getCurrSegInx];
    int currPointInx = [dirGiver getCurrPointInx];
    
    double currLength = 0;
    for(int i=0; i<= currSegInx - 1; i++) {
        currLength += [[segmentArray objectAtIndex:i] getLength];
    }
    if (currSegInx >= 0) currLength += [[segmentArray objectAtIndex:currSegInx] getLengthTillIndex:currPointInx];
    return currLength;
}

// Compute the bearing to switch from one segment to another
// \param fromSegInx the index of the 'from' segment
// \param toSegInx the index of the 'to segment
- (CGFloat) getBearingFromSegmentIndex: (int) fromSegInx to: (int)toSegInx
{
    return [[segmentArray objectAtIndex: fromSegInx] getBearingToSegment:[segmentArray objectAtIndex:toSegInx]];
}

// Collapse small segments together
-(void) trimSegment
{
    NSMutableArray* newSegArray = [[NSMutableArray alloc] init];
    Segment* prevSeg = [segmentArray objectAtIndex:0];
    Segment* currSeg = nil;
    Segment* mergeSeg = nil;
    
    for(int i=1; i<[segmentArray count]; i++)
    {
        currSeg = [segmentArray objectAtIndex:i];
        mergeSeg = [prevSeg mergeWithSegment:currSeg]; // try to merge the two segments
        if (mergeSeg == nil)
        {
            // cannot merge
            [newSegArray addObject:prevSeg];
            prevSeg = currSeg;
        }
        else
        {
            // can merge
            prevSeg = mergeSeg;
        }
    }
    
    [newSegArray addObject:prevSeg];
    segmentArray = newSegArray;
}

// Compute bearing for each segment to the next one
// used for DirectionGiver
- (void) computeSegmentsBearing
{
    for(int i=1; i<[segmentArray count]; i++)
    {
        [[segmentArray objectAtIndex:i] updateBearingFromSegment:[segmentArray objectAtIndex:i-1]];
    }
    [[segmentArray firstObject] updateBearingFromSegment:nil];
}

/*
function _fromCompressedGeometry( String str, SpatialReference sr) {
    var xDiffPrev = 0,
    yDiffPrev = 0,
    points = [],
    x, y,
    strings,
    coefficient;
    
    // Split the string into an array on the + and - characters
    strings = str.match(/((\+|\-)[^\+\-]+)/g);
    
    // The first value is the coefficient in base 32
    coefficient = parseInt(strings[0], 32);
    
    for (var j = 1; j < strings.length; j += 2) {
        // j is the offset for the x value
        // Convert the value from base 32 and add the previous x value
        x = (parseInt(strings[j], 32) + xDiffPrev);
        xDiffPrev = x;
        
        // j+1 is the offset for the y value
        // Convert the value from base 32 and add the previous y value
        y = (parseInt(strings[j + 1], 32) + yDiffPrev);
        yDiffPrev = y;
        
        points.push([x / coefficient, y / coefficient]);
    }
    
    return points;
}
*/

@end
