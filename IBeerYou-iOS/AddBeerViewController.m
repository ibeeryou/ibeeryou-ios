//
//  AddBeerViewController.m
//  IBeerYou-iOS
//
//  Created by Jean-Loup YU on 13/01/2015.
//
//

#import "AddBeerViewController.h"
#import "Parse/Parse.h"

@interface AddBeerViewController ()

@end

@implementation AddBeerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Load the friend data
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set up the delegate
        self.delegate = self;
    }
    return self;
}

/*
 * Event: Error during data fetch
 */
- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                       handleError:(NSError *)error
{
    NSLog(@"Error during data fetch.");
}

/*
 * Event: Data loaded
 */
- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker
{
    NSLog(@"Friend data loaded.");
}


/*
 * Event: Selection changed
 */
- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    NSLog(@"Current friend selections: %@", friendPicker.selection);
}

/*
 * Event: Done button clicked
 */
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    FBFriendPickerViewController *friendPickerController =
    (FBFriendPickerViewController*)sender;
    NSLog(@"Selected friends: %@", friendPickerController.selection);
    
    // retrieve user from database
    PFQuery *query = [PFUser query];
    [query whereKey:@"id" equalTo:friendPickerController.selection.firstObject[@"id"]];
    NSArray *foundUsers = [query findObjects];
    
    // Create a new Beer object and create relationship with PFUser
    PFObject *newBeer = [PFObject objectWithClassName:@"Beer"];
    
    [newBeer setObject:foundUsers.firstObject forKey:@"creditor"];  // add selected PFUser as creditor
    
    [newBeer setObject:[PFUser currentUser] forKey:@"debitor"]; // add current PFUser as debitor
    
    // Set ACL permissions for added security
    PFACL *postACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [postACL setPublicReadAccess:YES];
    [newBeer setACL:postACL];
    
    // Save new Beer object in Parse
    [newBeer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Dismiss the friend picker
            [[sender presentingViewController] dismissModalViewControllerAnimated:YES];
        }
    }];
    
    // Dismiss the friend picker
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[[sender presentingViewController] dismissModalViewControllerAnimated:YES];
    
    
    
}

/*
 * Event: Cancel button clicked
 */
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    NSLog(@"Canceled");
    // Dismiss the friend picker
    [[sender presentingViewController] dismissModalViewControllerAnimated:YES];
}
@end
