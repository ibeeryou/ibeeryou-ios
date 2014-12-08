//
//  NewBeerViewController.m
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//

#import "NewBeerViewController.h"
#import "Parse/Parse.h"

@implementation NewBeerViewController

@synthesize textView;

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    [self setTitle:@"New beer with"];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 310, 186)];
    [textView setFont:[UIFont systemFontOfSize:16]];
    [textView becomeFirstResponder];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonTouchHandler:)]];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTouchHandler:)]];
    
    [self.view addSubview:textView];
}


#pragma mark - Button handlers

- (void)addButtonTouchHandler:(id)sender
{
    // Create a new Beer object and create relationship with PFUser
    PFObject *newBeer = [PFObject objectWithClassName:@"Beer"];
    
    // TODO : replace with PFUser
    [newBeer setObject:[textView text] forKey:@"creditor"];
    
    [newBeer setObject:[PFUser currentUser] forKey:@"debitor"]; // One-to-Many relationship created here!
    
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

@end

