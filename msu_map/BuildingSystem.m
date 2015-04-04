//
//  BuildingSystem.m
//  msu_map
//
//  Created by Minh Pham on 11/10/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import "BuildingSystem.h"

// file name should not contain the extension (just the way xcode work)
// Building list file
// the default extension is txt
#define BuildingFile @"building_sorted"

// file name should not contain the extension (just the way xcode work)
// Exception building o be ignored
// the default extension is txt
#define ExceptionFile @"notWorkingBuilding"


// Manage the list of buildings
// Primary function is loading the building list
// Possibly handle the search
@implementation BuildingSystem {
    NSArray* buildingArray;
}

// Initialize the building list
// Create building list from text file
- (id) init
{
    // Get the path, then load the content
    NSString *path = [[NSBundle mainBundle] pathForResource: BuildingFile ofType:@"txt"];
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\n"];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init]; // empty bulding list
    NSArray* exceptionList = [self getExceptionList]; // list of building to ignore
    
    for (NSString* line in lines) {
        if ([line length] < 5) break; // guard a against empty line
        
        // Check for the all cap name in the line
        NSString *name = [[self trim:[[line componentsSeparatedByString:@","] objectAtIndex:1]] uppercaseString];
        if ([exceptionList containsObject:name]) continue; // ignore building name in exception list
        
        Building *tempBuilding = [[Building alloc] init:line];
        [tempArray addObject:tempBuilding];
    }
    
    buildingArray = [[NSArray alloc] initWithArray:tempArray];
    //NSLog(filename, @"");
    
    tempArray = nil;
    return self;
}

// Return the list of buildings
- (NSArray*) getBuildings
{
    return buildingArray;
}

// Return list of name of buildings to be ignored
- (NSArray*) getExceptionList
{
    // open exception file
    NSString *path = [[NSBundle mainBundle] pathForResource: ExceptionFile ofType:@"txt"];
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByString:@"\n"];
    
    // create an empty result list
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSString* line in lines) {
        if ([line characterAtIndex:0] == '#') continue; // ignore meta data
        NSString* name = [[self trim:line] uppercaseString];
        [result addObject:name];
    }
    
    return result;
}
                          
// Get rid of all white space of the input string
- (NSString*) trim: (NSString*) text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
