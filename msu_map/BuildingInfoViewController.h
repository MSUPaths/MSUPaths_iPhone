//
//  BuildingInfoViewController.h
//  msu_map
//
//  Created by Minh Pham on 11/11/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Building;

// View Building info and button to et direction
@interface BuildingInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *abbreviation;
@property (weak, nonatomic) IBOutlet UIImageView *image;

- (IBAction)getDirection:(id)sender;

- (void) initWithBuilding: (Building*) b;
@end
