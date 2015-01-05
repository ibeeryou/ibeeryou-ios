/**
 * Copyright (c) 2014, Parse, LLC. All rights reserved.
 *
 * You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 * copy, modify, and distribute this software in source code or binary form for use
 * in connection with the web services and APIs provided by Parse.

 * As with any software that integrates with the Parse platform, your use of
 * this software is subject to the Parse Terms of Service
 * [https://www.parse.com/about/terms]. This copyright notice shall be
 * included in all copies or substantial portions of the software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import "LoginViewController.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "AppDelegate.h"

@implementation LoginViewController

#pragma mark -
#pragma mark Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Login with Facebook";
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self _presentTabBarViewControllerAnimated:NO];
    }
}

#pragma mark -
#pragma mark Login

- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_birthday", @"user_location", @"email", @"user_friends"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator

        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                
                // Get user's personal information
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        // Set user's information
                        NSDictionary *userData = (NSDictionary *)result;
                        NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
                        
                        NSString *facebookID = userData[@"id"];
                        if (facebookID) {
                            userProfile[@"facebookId"] = facebookID;
                        }
                        
                        NSString *name = userData[@"name"];
                        if (name) {
                            userProfile[@"name"] = name;
                        }
                        
                        NSString *email = userData[@"email"];
                        if (email) {
                            userProfile[@"email"] = email;
                        }
                        
                        NSString *location = userData[@"location"][@"name"];
                        if (location) {
                            userProfile[@"location"] = location;
                        }
                        
                        NSString *birthday = userData[@"birthday"];
                        if (birthday) {
                            userProfile[@"birthday"] = birthday;
                        }
                        
                        userProfile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
                        
                        [[PFUser currentUser] setObject:facebookID forKey:@"id"];
                        [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                        [[PFUser currentUser] setObject:email forKey:@"email"];
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            // Get user's friend information
                            [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                if (!error) {
                                    NSArray *data = [result objectForKey:@"data"];
                                    NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
                                    
                                    NSLog(@"Found: %lu friends", data.count);
                                    NSLog(@"friends: %@", result);
                                    
                                    for (NSDictionary *friendData in data) {
                                        [facebookIds addObject:[friendData objectForKey:@"id"]];
                                    }
                                    
                                    [[PFUser currentUser] setObject:facebookIds forKey:@"facebookFriends"];
                                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                        // We're in!
                                        [self dismissViewControllerAnimated:YES completion:NULL];
                                    }];
                                } else {
                                    [self showErrorAlert];
                                }
                            }];
                        }];
                    } else {
                        [self showErrorAlert];
                    }
                }];
                
                
                
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [self _presentTabBarViewControllerAnimated:YES];
        }
    }];

    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

#pragma mark - ()

- (void)showErrorAlert {
    [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                message:@"We were not able to create your profile. Please try again."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark -
#pragma mark TabBarViewController

- (void)_presentTabBarViewControllerAnimated:(BOOL)animated {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:appDelegate.tabBarController];
}


@end
