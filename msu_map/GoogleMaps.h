//
//  GoogleMaps.h
//  msu_map
//
//  Created by Pham Khac Minh on 4/10/13.
//  Copyright (c) 2013 Minh Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface GoogleMaps : NSObject

// Query google API to get path from f to t
// \return an array of lat, long
-(NSArray*) getRoutesFrom:(CLLocationCoordinate2D) f
                       to: (CLLocationCoordinate2D) t;
@end
