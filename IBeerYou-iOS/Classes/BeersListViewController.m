//
//  BeersListViewController.m
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//

//

#import "BeersListViewController.h"
#import "NewBeerViewController.h"
#import "Parse/Parse.h"

@implementation BeersListViewController

@synthesize beerArray;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Beers"];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonHandler:)]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBeerButtonHandler:)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([PFUser currentUser])
        [self refreshButtonHandler:nil];
}

#pragma mark - Button handlers

- (void)refreshButtonHandler:(id)sender
{
    //Create query for all Beer object by the current user
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Beer"];
    [postQuery whereKey:@"debitor" equalTo:[PFUser currentUser]];
    
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            beerArray = objects;
            [self.tableView reloadData];
        }
    }];
}

- (void)addBeerButtonHandler:(id)sender
{
    NewBeerViewController *newBeerViewController = [[NewBeerViewController alloc] init];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:newBeerViewController] animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return beerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell with the textContent of the Beer as the cell's text label
    PFObject *beer = [beerArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:[[beer objectForKey:@"creditor"] fetchIfNeeded][@"profile"][@"name"]];
    
    return cell;
}


@end

