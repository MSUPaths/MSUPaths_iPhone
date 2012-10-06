//
//  MSUNavViewController.h
//  MSUNav
//
//  Created by Nicholas Slocum on 1/22/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MSUNavViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    NSString *_buildingName;
}

@property (nonatomic, strong) NSString *buildingName;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) NSNumber *buildingID;

@end
