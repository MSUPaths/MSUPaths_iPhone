//
//  LocationsTableViewController.h
//  MSUNav
//
//  Created by Nicholas Slocum on 3/8/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsTableViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate> {
    NSArray *_locations;
    NSMutableArray *_filteredLocations;
    UISearchDisplayController *_searchController;
    NSString *_selectedBuilding;
}

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSMutableArray *filteredLocations;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSString *selectedBuilding;

@end
