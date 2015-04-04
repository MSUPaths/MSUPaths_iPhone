//
//  jsonParserTest.m
//  msu_map
//
//  Created by Pham Khac Minh on 2/26/15.
//  Copyright (c) 2015 Minh Pham. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONParser.h"

@interface jsonParserTest : XCTestCase
@end

@implementation jsonParserTest {
    JSONParser* parser;
}

- (void)setUp {
    [super setUp];
    parser = [JSONParser alloc];
    //Code
}

- (void)tearDown {
    //code
    [super tearDown];
}

- (void)testBasicRoute {
    SegmentHandler* segHandler = [parser getSegmentFromLat:-84.480924 :42.7250467 :-84.478145 :42.7327347];
    if (segHandler == nil) XCTFail("Cannot create seghandler");
    
}
@end
