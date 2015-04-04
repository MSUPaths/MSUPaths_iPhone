//
//  GoogleMaps.m
//  msu_map
//
//  Created by Pham Khac Minh on 4/10/13.
//  Copyright (c) 2013 Minh Pham. All rights reserved.
//

#import "GoogleMaps.h"

@implementation GoogleMaps


// Probably don't want to touch it
// Decode polyline from points string received from Google maps API
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		//printf("[%f,", [latitude doubleValue]);
		//printf("%f]", [longitude doubleValue]);
		//CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		//[array addObject:loc];
        [array addObject:longitude];
        [array addObject:latitude];
	}
	
	return array;
}

// Get Path from location to another location using google maps api
-(NSArray*) getRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    // Change location to address string to be given to the url
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.google.com/maps?output=dragdir&dirflg=w&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	
    
    // Get the result
	NSData *apiResponse = [NSData dataWithContentsOfURL:apiUrl];
    
    if (apiResponse)
    {
        // Need more error testing
        return [self getPathFromUrlData:apiResponse];
    }
    else
    {
        NSLog(@"Error in retrieving path from google server");
        NSLog(@"api url: %@", apiUrl);
        return nil;
    }
}

// Get the points string from Google Maps data
// then call decodePolyline to get the path
-(NSArray*)getPathFromUrlData:(NSData*) responseData
{
    NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // Get the points string
    // this is a dumb way of doing it because I don't know how to work wih JSON object yet
    NSRange pointStart = [responseString rangeOfString:@"points"];
    NSRange pointEnd = [responseString rangeOfString:@",levels:"];
    NSRange pointRange;
    pointRange.location = pointStart.location + pointStart.length + 2;
    pointRange.length = pointEnd.location - pointRange.location - 1;
    
    //NSLog(@"%@", [responseString substringWithRange:pointRange]);
    return [self decodePolyLine:[[responseString substringWithRange:pointRange] mutableCopy]];
}

@end
