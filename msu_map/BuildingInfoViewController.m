//
//  BuildingInfoViewController.m
//  msu_map
//
//  Created by Minh Pham on 11/11/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import "BuildingInfoViewController.h"

#include "Building.h"
#include "MapViewController.h"

#define MapViewIndex 1

@interface BuildingInfoViewController ()

@end

@implementation BuildingInfoViewController {
    Building *myBuilding;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

// Display the building name, building image
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.name.text = [myBuilding commonName];
    self.abbreviation.text = [myBuilding abbreviation];
    
    // Get the path, then load the content
    [self.image setImage: [myBuilding getImage]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setName:nil];
    [self setAbbreviation:nil];
    [self setImage:nil];
    [super viewDidUnload];
}

// Action when press the button
// Update mapView building id and
// Switch to mapView
- (IBAction)getDirection:(id)sender {
    UIViewController *view = self.tabBarController.viewControllers[MapViewIndex];
    if ([(id)view isKindOfClass:[MapViewController class]])
    {
        [self.tabBarController setSelectedIndex:MapViewIndex];
        [(id)view drawRouteFromCurrentLocationToBuilding:myBuilding]; // downcasting
        //[(id)view drawRoute]; // downcasting
    }
    else {
        NSLog(@"Wrong MapViewIndex");
    }

}

// initialize with a pointer to a building
- (void) initWithBuilding: (Building*) b {
    myBuilding = b;
}


@end
