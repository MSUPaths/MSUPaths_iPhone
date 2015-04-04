//
//  AStarPathFinder.h
//  msu_map
//
//  Created by Pham Khac Minh on 4/24/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "MapSystem.h"

@interface AStarPathFinder : NSObject

@property (strong, readonly) MapSystem* graph;

// initialize with a map system
-(id) initWithGraph: (MapSystem*) mapSystem;

// find path from one vertex to another one
-(NSArray*) findPathFromVertex: (MapVertex*) startVertex to: (MapVertex*) endVertex;

@end
