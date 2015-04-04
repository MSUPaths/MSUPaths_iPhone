//
//  MinHeap.m
//  msu_map
//
//  Created by Pham Khac Minh on 4/24/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import "MinHeap.h"
#include "MapVertex.h"

// TO BE IMPLEMENTED
@implementation MinHeap {
    NSMutableArray* _array;
}


-(id) init {
    _array = [[NSMutableArray alloc] init];
    return self;
}

// Add object to min heap
-(void) addObject:(id)anObject {
    [_array addObject:anObject];
}

// Extract the smallest value from the heap
-(id) extractMin {
    id minObject = [_array firstObject];
    
    for (id object in _array) {
        if ([object isSmallerThan:minObject]) minObject = object;
    }
    
    [_array removeObject:minObject];
    return minObject;
}

// Return the count of the array
- (NSUInteger) count {
    return [_array count];
}

// Check if the heap contains object
-(bool) containsObject: (id) anObject {
    return [_array containsObject:anObject];
}

@end
