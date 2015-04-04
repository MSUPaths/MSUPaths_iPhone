//
//  MinHeap.h
//  msu_map
//
//  Created by Pham Khac Minh on 4/24/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <Foundation/Foundation.h>


// A min heap structure to be used with AStarPathFinder
// The elements must have a function call isSmallerThan used to compare
// -(bool) isSmallerThan: (id) anObject;
@interface MinHeap : NSObject

// Add object to the heap
-(void) addObject:(id)anObject;

// Extract the smallest value from the heap
-(id) extractMin;

// get the count of the heap
-(NSUInteger) count;

// Check if the heap contains object
-(bool) containsObject: (id) anObject;

@end