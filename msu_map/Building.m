//
//  Building.m
//  msu_map
//
//  Created by Minh Pham on 11/10/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import "Building.h"

@implementation Building

@synthesize abbreviation;
@synthesize name;
@synthesize ID;
@synthesize commonName;
@synthesize description;
@synthesize imageName;
@synthesize alias;
@synthesize latitude;
@synthesize longitude;


// Please use this initialize to create a building object
// the line format supposed to be:
// ABB, MASON AND ABBOT HALL, 0302, University Housing - REsidence Hall, abbot, latitude, longitude, Abbot Hall, (alias)
- (id) init:(NSString *)line
{
    NSArray* lineArray = [line componentsSeparatedByString:@","];
    // use trim to get rid of whitespace
    abbreviation = [self trim:lineArray[0]];
    name = [self trim:lineArray[1]];
    ID = [self trim:lineArray[2]];
    description = [self trim:lineArray[3]];
    imageName = [self trim:lineArray[4]] ;
 
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    latitude = [f numberFromString:[self trim:lineArray[5]]];
    longitude = [f numberFromString:[self trim:lineArray[6]]];

    commonName = [self trim:lineArray[7]];
    
    if (lineArray.count > 8) {
        // if there is an alias
        alias = [self trim:lineArray[8]];
    }
    else {
        alias = nil;
    }
    
    return self;
}

// Get an the image from resources
// the file of image is from imageName
// using default extension, which is png
- (UIImage*) getImage
{
    if (self == nil) {
        return nil;
    }
    
    return [UIImage imageNamed:imageName];
}

// Get rid of all white space of the input string
- (NSString*) trim: (NSString*) text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end