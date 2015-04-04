//
//  directionTest.m
//  msu_map
//
//  Created by Pham Khac Minh on 3/5/14.
//  Copyright (c) 2014 Minh Pham. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SegmentHelper.h"
#import "Segment.h"

@interface directionTest : XCTestCase

@end

@implementation directionTest {
    Segment* sampleSegment;
    Segment* sampleSegment2;
    SegmentHelper* segHelper;
    bool flag;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    NSArray* path = [[NSArray alloc] initWithObjects:@"-84.4761831793133", @"42.7291042366155",
                     @"-84.476184594857", @"42.7290366461514",
                     @"-84.4761860103973", @"42.7289690556866", nil];
    sampleSegment = [[Segment alloc] initWithPath:path length:49.27 name:@"test" type:@"testSeg"];
    
    path = [[NSArray alloc] initWithObjects: @"-84.4770156675682", @"42.729200371249",
            @"-84.4769930790042",@" 42.7292002816821",
            @"-84.4769705261426",@" 42.7291993414729",
            @"-84.4769480678823",@" 42.7291975530767",
            @"-84.4767791155121",@" 42.7291808691417",
            @"-84.4764216315129",@" 42.7291425303186", nil];
    sampleSegment2 = [[Segment alloc] initWithPath:path length:161.06 name:@"test" type:@"testSeg"];
    
    segHelper = [SegmentHelper alloc];
    flag = true;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

// test angle function
- (void) testAngle
{
    CGPoint mid = CGPointMake(1.0,0.0);
    CGPoint aPoint = CGPointMake(0.0,0.0);
    CGPoint bPoint = CGPointMake(1.0,1.0);
    
    CGFloat bearing = [segHelper getBearingFrom:aPoint intersect:mid to:bPoint];
    CGFloat bearing2 = [segHelper getBearingFrom:bPoint intersect:mid to:aPoint];
    if (fabs(360-bearing-bearing2) > 1) XCTFail(@"Wrong angle bearing");
}

// test checkMidPoint function
- (void)testMidPoint
{
    CGPoint mid = CGPointMake(1.0,0.0);
    CGPoint aPoint = CGPointMake(0.0,0.0);
    CGPoint bPoint = CGPointMake(2.0,0.0);
    
    if ([segHelper checkMidPoint:mid between:aPoint and:bPoint] == false) XCTFail(@"Wrong midpoint 1");
    
    mid = CGPointMake(1.0,0.1);
    if ([segHelper checkMidPoint:mid between:aPoint and:bPoint] == false) XCTFail(@"Wrong midpoint 2");
    
    mid = CGPointMake(1.0,-0.1);
    if ([segHelper checkMidPoint:mid between:aPoint and:bPoint] == false) XCTFail(@"Wrong midpoint 3");
    
    mid = CGPointMake(1.0,0.2);
    if ([segHelper checkMidPoint:mid between:aPoint and:bPoint] == true) XCTFail(@"Wrong midpoint 4");
    
    mid = CGPointMake(2.0,0.2);
    if ([segHelper checkMidPoint:mid between:aPoint and:bPoint] == true) XCTFail(@"Wrong midpoint 5");
}

// test distance formula
- (void) testDistance
{
    double dist = [segHelper computeDistanceWithLat:-84.4764031621341 long:42.7291385237578 andLat:-84.4762470495053 long:42.7291169136303];
    flag = dist > 43 || dist < 42;
    if (flag) XCTFail(@"Wrong distance: %f", dist);
    
    dist = [segHelper computeDistanceWithLat:-84.4762470495053 long:42.7291169136303 andLat:-84.4761831793133 long:42.7291042366155];
    flag = dist > 18 || dist < 17;
    if (flag) XCTFail(@"Wrong distance: %f", dist);

    dist = [segHelper computePathDistance:[sampleSegment getPath] ];
    flag = dist > 37 || dist < 36;
    // Weird distance due to the final segment, but about: 36.67
    if (flag) XCTFail(@"Wrong path distance: %f", dist);
    
    dist = [segHelper computePathDistance:[sampleSegment2 getPath] ];
    flag = dist > 162 || dist < 160;
    if (flag) XCTFail(@"Wrong path distance: %f", dist);
}

// test find index of midpoint function
- (void) testMidPointIndex
{
    int i = [sampleSegment findIndexOfLat:@42.5 long:@-84.5];
    flag = (i >= 0);
    if (flag) XCTFail(@"Wrong mid point index %d", i);
    
    i = [sampleSegment findIndexOfLat:@42.7290704414 long:@-84.4761838871];
    flag = (i != 3);
    if (flag) XCTFail(@"Wrong mid point index %d", i);
    
    i = [sampleSegment findIndexOfLat:@42.7290366461514 long:@-84.476184594857];
    flag = (i != 3);
    if (flag) XCTFail(@"Wrong mid point index %d", i);
}

@end
