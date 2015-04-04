//
//  BuildingViewController.m
//  msu_map
//
//  Created by Minh Pham on 11/11/12.
//  Copyright (c) 2012 Minh Pham. All rights reserved.
//

#import "BuildingTableViewController.h"

#include "BuildingInfoViewController.h"

@interface BuildingTableViewController ()

@end

@implementation BuildingTableViewController{
    BuildingSystem *buildings;
    NSArray* searchResults;
    int indexList[26]; // Map index 'A' to row index
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        searchResults = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    buildings = [[BuildingSystem alloc] init];
    
    
    // Make index list, i.e. map letter 'A' to its first appearance in the table
    unichar prevLetter = 'A';
    indexList[0] = 0;
    int count = 1;
    for (int i=0; i<buildings.getBuildings.count; i++)
    {
        unichar currLetter = [[[[buildings.getBuildings objectAtIndex:i] commonName] uppercaseString] characterAtIndex:0];
        if (prevLetter < currLetter)
        {
            for (int j=prevLetter;j<currLetter;j++)
            {
                indexList[count] = i;
                count++;
            }
            prevLetter = currLetter;
        }
    }
    
    // For some of the the last letter that didn't get count
    for (int i=count; i<26; i++) indexList[i] = (int)buildings.getBuildings.count-1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/

// Number of row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // in search table
        return [searchResults count];
        
    } else {
        // in list table
        return buildings.getBuildings.count;
    }
}

// Contain of each row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Basic setup
    static NSString *CellIdentifier = @"BuildingName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // in search table
        //NSInteger inx = [[searchResults objectAtIndex:indexPath.row] integerValue];
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] commonName];
    } else {
        // in list table
        cell.textLabel.text = [[buildings.getBuildings objectAtIndex:indexPath.row] commonName];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// Select a building from the list
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

// Change view
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBuildingInfo"]) {     
        BuildingInfoViewController *destViewController = segue.destinationViewController;
        
        Building *selectedBuilding = nil;
        
        if ([self.searchDisplayController isActive]) {
            selectedBuilding = [searchResults objectAtIndex:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow].row];
        } else {
            NSInteger inx = [self.tableView indexPathForSelectedRow].row;
            selectedBuilding = [[buildings getBuildings] objectAtIndex:inx];
       }

        [destViewController initWithBuilding:selectedBuilding];
    }

}

// Update the searchResults array to get search table based on query
// This is where the search query is done using predicate (if-else statement)
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"(SELF.commonName contains[cd] %@) OR (SELF.alias contains[cd] %@)",
                                    searchText, searchText];
    
    searchResults = [[buildings getBuildings] filteredArrayUsingPredicate:resultPredicate];

}

// Search display controller (not useful)
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

// Search bar segue to change view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier: @"showBuildingInfo" sender: self];
    }
}

// Array for the right scroll bar
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return[NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

// Get the index of the row that match the title to the right scroll bar
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexList[index] inSection:0];
    [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    return index;
}
@end
