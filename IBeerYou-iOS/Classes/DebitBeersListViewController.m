//
//  DebitBeersListViewController.m
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//

#import "DebitBeersListViewController.h"
#import "AddBeerViewController.h"
#import "Parse/Parse.h"

@implementation DebitBeersListViewController

@synthesize beerArray;

// TODO: delete duplicated code with CreditBeersListViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"You Owe Beers"];
    
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
    [postQuery includeKey:@"creditor"];
    
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // do the count by debitor
            NSArray *sortedBeers;
            sortedBeers = [objects sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSDate *first = [(PFObject*)a objectForKey:@"creditor"][@"id"];
                NSDate *second = [(PFObject*)b objectForKey:@"creditor"][@"id"];
                return [first compare:second];
            }];
            
            // group and count
            PFObject *lastBeer = nil;
            NSMutableArray* groupedBeers = [[NSMutableArray alloc] init];
            int index = 0;
            for (PFObject *beer in sortedBeers) {
                if (lastBeer == nil || [lastBeer objectForKey:@"creditor"][@"id"] != [beer objectForKey:@"creditor"][@"id"]){
                    [groupedBeers addObject:beer];
                    lastBeer = beer;
                    index = 0;
                }
                index++;
                [lastBeer setObject:[NSNumber numberWithInt:index] forKey:@"beerCount"];
            }
            
            NSArray *groupedAndCountBeers =[groupedBeers sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSDate *first = [(PFObject*)a objectForKey:@"beerCount"];
                NSDate *second = [(PFObject*)b objectForKey:@"beerCount"];
                return -[first compare:second];
            }];

            
            //Save results and update the table
            beerArray = groupedAndCountBeers;
            [self.tableView reloadData];
        }
    }];
}

- (void)addBeerButtonHandler:(id)sender
{
    AddBeerViewController *friendPickerController = [[AddBeerViewController alloc] initWithNibName:@"AddBeerViewController" bundle:nil];
    [self.navigationController pushViewController:friendPickerController animated:YES];
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
    NSString* text = [NSString stringWithFormat:@"%@ (%@)", [beer objectForKey:@"creditor"][@"profile"][@"name"], [beer objectForKey:@"beerCount"]];
    [cell.textLabel setText:text];
    
    return cell;
}


@end

