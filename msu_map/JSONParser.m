//
//  JSONParser.m
//  msu_map
//
//  Created by Minh Pham on 11/10/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define BaseURL @"http://prod.gis.msu.edu/arcgis/rest/services/routing/ped_network/NAServer/Route/solve?"
#define CordSys @"GOOGLE"
#define TestURL @"http://gis.msu.edu/segmentsll.json"

#import "JSONParser.h"

NSDictionary* sampleQuery;

// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}


// Add methods to NSDictionary
// -----------------------------------------------
@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress;
-(NSData*)toJSON;
-(NSString*) urlEncodedString;
@end

@implementation NSDictionary(JSONCategories)

// Create const variables
// useful only for debugging purpose
+(void) initialize{
    sampleQuery = @{ @"ARGUMENTS" : @{
                             @"FROM" : @{
                                @"CORDSYS" : @"MI83_SF",
                                @"EASTING" : @13092317.4513359,
                                @"NORTHING" : @448071.95481256,
                                @"TYPE" : @"LOCATION",
                                      },
                             @"PATHTYPES" :         @[
                                 @"SIDEWALK",
                                 @"CWSTR",
                                 @"CROSSWALK",
                                 @"CWSGSTR",
                                 @"BIKELANE",
                                 @"RDCR",
                                 @"BIKEPATH"
                                 ],
                             @"TO" :         @{
                                 @"CORDSYS" : @"MI83_SF",
                                 @"EASTING" : @13092047.8362641,
                                 @"NORTHING" : @448929.222647803,
                                 @"TYPE" : @"LOCATION",
                                 },
                         
                             @"CORDSYS" : @"MI83_SF",
                                       },
       @"QUERYTYPE" : @"FINDPATHWITHTYPE",
       };
}

+ (NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

- (NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions
                                                  error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSString*) urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end
// -----------------------------------------------

@implementation JSONParser


- (NSData*)appendJSONDictionary:(NSDictionary*)queryDict
                          toURL:(NSString*)url
{
    NSString* queryString = [queryDict urlEncodedString];
    
    NSString* completeURL = [url stringByAppendingString:queryString];
    NSString* escapedUrlString = [completeURL stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    NSURL* escapedUrl = [NSURL URLWithString:escapedUrlString];
    return [NSData dataWithContentsOfURL: escapedUrl];
}

- (NSDictionary*)fetchedData:(NSData *)responseData
{
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    //    // Check if the query was successful
        if ([[json objectForKey:@"STATUS"] isEqualToString:@"FAILURE"]) {
            NSLog(@"Query failed: %@", [json objectForKey:@"REASON"]);
            return nil;
        }
    
    //NSDictionary* content = [json objectForKey:@"CONTENT"];
    return json;
}

- (NSNumber*)getBuildingID:(NSString*)buildingName
{
    // Construct the query to get the destination building's id
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"NAMESEARCH", @"QUERYTYPE",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            buildingName,  @"SEARCHTERM", nil],
                           @"ARGUMENTS", nil];
    
    NSData* data = [self appendJSONDictionary:query toURL:BaseURL];
    //    NSLog(@"data: %@", data);
    
    NSDictionary* content = [self fetchedData:data];  // TODO: should be executed in a seperate thread
    
    NSNumber* buildingID = [[[content objectForKey:@"DATA"] objectAtIndex:0] objectForKey:@"OBJECT_ID"];
    return buildingID;
    //    return [NSNumber numberWithInt:4];
}

- (SegmentHandler*)getSegmentToDestination:(NSString*)buildingID
                    :(NSNumber*)latitude
                    :(NSNumber*)longitude
{
    // Construct the json query
    latitude = @448929.222647803;
    longitude = @13092047.8362641;
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"FINDPATHWITHTYPE", @"QUERYTYPE",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            CordSys, @"CORDSYS",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             CordSys, @"CORDSYS",
                             latitude,  @"NORTHING",
                             longitude, @"EASTING",
                             @"LOCATION", @"TYPE", nil], @"FROM",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             CordSys, @"CORDSYS",
                             @"BUILDING",  @"OBJECT_TYPE",
                             buildingID,   @"OBJECT_ID",
                             @"IDENTIFIER", @"TYPE", nil], @"TO",
                            [NSArray arrayWithObjects: @"SIDEWALK", @"CWSTR", @"CROSSWALK", @"CWSGSTR", @"BIKELANE", @"RDCR",@"BIKEPATH", nil], @"PATHTYPES", nil],
                           @"ARGUMENTS", nil];
    
    query = sampleQuery;
    //NSLog(@"%@",query);
    
    NSData* data = [self appendJSONDictionary:query toURL:BaseURL];
    
    if (data)
    {
        NSDictionary* content = [self fetchedData:data];
        if (content)
        {
            return [[SegmentHandler alloc] initWithContent:content];
        }
        else return nil;
    }
    else{
        NSLog(@"Data from server is empty");
        return nil;
    }
}

// Get a path array to desination using old service
- (NSArray*)getPathToDestination:(NSString*)buildingID
                                :(NSNumber*)latitude
                                :(NSNumber*)longitude
{
    // Construct the json query
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"FINDPATH", @"QUERYTYPE",
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             latitude,  @"NORTHING",
                             longitude, @"EASTING",
                             @"LOCATION", @"TYPE", nil], @"FROM",
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"BUILDING",   @"OBJECT_TYPE",
                             buildingID,       @"OBJECT_ID",
                             @"IDENTIFIER", @"TYPE", nil], @"TO",
                            [NSArray arrayWithObjects: @"SIDEWALK", @"CWSTR", @"CROSSWALK", @"CWSGSTR", nil], @"PATHTYPES", nil],
                           @"ARGUMENTS", nil];
    
    NSData* data = [self appendJSONDictionary:query toURL:BaseURL];
    
    if (data)
    {
        NSDictionary* content = [self fetchedData:data];    // TODO: should be executed in a seperate thread
        return [content objectForKey:@"GEOMETRY"];
    }
    else{
        return nil;
    }
}

- (SegmentHandler*)getSegmentFromLat: (double) fromLat
                                    : (double) fromLong
                                    : (double) toLat
                                    : (double) toLong {
    
    
    NSMutableDictionary* query = [[NSMutableDictionary alloc] init];
    
    query[@"stops"] = [NSString stringWithFormat:@"%f,%f;%f,%f",
                         fromLat, fromLong, toLat, toLong];
    query[@"f"] = @"pjson";
    query[@"outSR"] = @"4236";
    NSData* data = [self appendJSONDictionary:query toURL:BaseURL];
    if (data)
    {
        NSDictionary* content = [self fetchedData:data];    // TODO: should be executed in a seperate thread
        NSArray* message = [content objectForKey:@"messages"];
        //if (message != nil) NSLog(@"%@",message);
        NSDictionary* routes = [content objectForKey:@"routes"];
        NSArray* features = [routes objectForKey:@"features"];
        NSDictionary* feature = [features objectAtIndex:0];
        NSDictionary* geometry = [feature objectForKey:@"geometry"];
        NSArray* paths = [geometry objectForKey:@"paths"];
        
        return [[SegmentHandler alloc] initWithPaths:paths];
    }
    else{
        return nil;
    }
}

// Get a test segment using TestURL
// for developing and debugging purpose
- (SegmentHandler*) getTestSegment
{
    NSDictionary* query = nil;
    NSData* data = [self appendJSONDictionary:query toURL:TestURL];
    
    if (data)
    {
        NSDictionary* content = [self fetchedData:data];
        if (content)
        {
            return [[SegmentHandler alloc] initWithContent:content];
        }
        else return nil;
    }
    else{
        NSLog(@"Data from server is empty");
        return nil;
    }
}

@end
