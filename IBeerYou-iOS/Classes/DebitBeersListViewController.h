//
//  DebitBeersListViewController.h
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//


#import <UIKit/UIKit.h>

@interface DebitBeersListViewController : UITableViewController

@property (nonatomic, strong) NSArray *beerArray;

- (void)addBeerButtonHandler:(id)sender;
- (void)refreshButtonHandler:(id)sender;

@end


