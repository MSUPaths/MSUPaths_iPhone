//
//  LocationsTableViewController.m
//  MSUNav
//
//  Created by Nicholas Slocum on 3/8/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#import "LocationsTableViewController.h"
#import "MSUNavViewController.h"


@implementation LocationsTableViewController

@synthesize locations = _locations;
@synthesize filteredLocations = _filteredLocations;
@synthesize searchController = _searchController;
@synthesize selectedBuilding = _selectedBuilding;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create search bar and add it to table view
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    
    // Load locations from plist file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"];    
    self.locations = [NSArray arrayWithContentsOfFile:path];
    self.filteredLocations = [NSMutableArray arrayWithArray:self.locations];
}

- (void)viewDidUnload
{
    self.locations = nil;
    self.filteredLocations = nil;
    self.searchController = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.filteredLocations removeAllObjects];
    [self.locations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])]) {
            [self.filteredLocations addObject:obj];
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.filteredLocations = [NSMutableArray arrayWithArray:self.locations];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Location";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.filteredLocations objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedBuilding = [self.filteredLocations objectAtIndex:indexPath.row];
    return indexPath;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setBuildingName:self.selectedBuilding];
}

@end
