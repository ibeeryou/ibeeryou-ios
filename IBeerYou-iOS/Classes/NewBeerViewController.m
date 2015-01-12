//
//  NewBeerViewController.m
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//

#import "NewBeerViewController.h"
#import "Parse/Parse.h"

@interface NewBeerViewController ()

@end

@implementation NewBeerViewController

@synthesize userPicker;
@synthesize users =_users;
@synthesize selected_user =_selected_user;

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    // retrieve friends of current users
    PFQuery *query = [PFUser query];
    [query whereKey:@"id" containedIn:[[PFUser currentUser] objectForKey:@"facebookFriends"]];
    [query setLimit:100];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded. The first 100 objects are available in objects
            _users = objects;
            [ self.userPicker reloadAllComponents ];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [self setTitle:@"New beer with"];
    userPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    userPicker.delegate = self;
    userPicker.dataSource = self;
    userPicker.showsSelectionIndicator = YES;
    
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonTouchHandler:)]];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTouchHandler:)]];
    [self.view addSubview:userPicker];

}


#pragma mark - Button handlers

- (void)addButtonTouchHandler:(id)sender
{
    // Create a new Beer object and create relationship with PFUser
    PFObject *newBeer = [PFObject objectWithClassName:@"Beer"];
    
    [newBeer setObject:_selected_user forKey:@"creditor"];  // add selected PFUser as creditor
    
    [newBeer setObject:[PFUser currentUser] forKey:@"debitor"]; // add current PFUser as debitor
    
    // Set ACL permissions for added security
    PFACL *postACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [postACL setPublicReadAccess:YES];
    [newBeer setACL:postACL];
    
    // Save new Beer object in Parse
    [newBeer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the viewController upon success
        }
    }];
}

- (void)cancelButtonTouchHandler:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the viewController upon cancel
}

#pragma mark - UIPickerView Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _users.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PFUser *user = [_users objectAtIndex:row];
    _selected_user = user;
    return  user[@"profile"][@"name"];
}


@end

