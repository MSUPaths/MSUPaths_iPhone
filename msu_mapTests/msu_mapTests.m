//
//  msu_mapTests.m
//  msu_mapTests
//
//  Created by Minh Pham on 10/11/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import "msu_mapTests.h"

#import "JSONParser.h"
#import "SegmentHandler.h"
#import "Segment.h"

@implementation msu_mapTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testQuery
{
    JSONParser *parse = [JSONParser alloc];
    SegmentHandler *segHandler = [parse getTestSegment];
    if (segHandler) NSLog(@"Successful retrieve segments from server");
    else XCTFail(@"Unsuccessful query");
    
    Segment* sampleSegment = [[segHandler getAllSegments] objectAtIndex:5];
    int i = [sampleSegment findIndexOfLat:@42.7290366461514 long:@-84.476184594857];
    bool flag = (i != 3);
    if (flag) XCTFail(@"Wrong mid point index %d", i);
    [segHandler trimSegment];
    
    i = [sampleSegment findIndexOfLat:@42.7290704414 long:@-84.4761838871];
    flag = (i != 3);
    if (flag) XCTFail(@"Wrong mid point index %d", i);
}

@end
