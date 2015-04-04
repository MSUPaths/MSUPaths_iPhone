//
//  MapEdge.h
//  msu_map
//
//  Created by Pham Khac Minh on 4/23/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Segment.h"

// An edge in map
@interface MapEdge : Segment

@property (readonly) int startVertexId; // start vertex id number
@property (readonly) int endVertexId; // end vertex id number

// Initialize edge using a string
- (id) init:(NSString *)line;

// Reorienting the edge based on startVertexId and endVertexId
- (void) orientWithStart: (int) startId end: (int) endId;

@end
