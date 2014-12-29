//
//  CreditBeersListViewController.h
//  IBeerYou-iOS
//
//  Created by Jean-Loup YU on 29/12/2014.
//
//

#import <UIKit/UIKit.h>

@interface CreditBeersListViewController : UITableViewController

@property (nonatomic, strong) NSArray *beerArray;

- (void)addBeerButtonHandler:(id)sender;
- (void)refreshButtonHandler:(id)sender;

@end