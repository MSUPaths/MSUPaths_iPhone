//
//  Building.h
//  msu_map
//
//  Created by Minh Pham on 11/10/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

@import UIKit;

// Hold info for building
// create from build_master.txt through BuildingSystem
@interface Building : NSObject

@property (strong) NSString* abbreviation; // building abbreviation
@property (strong) NSString* name; // building name in all caps
@property (strong) NSString* ID; // building id
@property (strong) NSString* commonName; // building common name
@property (strong) NSString* description; // building description
@property (strong) NSString* imageName; // the name of the image file
@property (strong) NSString* alias; // other name of building
@property (strong) NSNumber* latitude; // latitude of the building
@property (strong) NSNumber* longitude; // longitude of the building

- (id) init: (NSString*) line;
- (UIImage*) getImage;

@end
