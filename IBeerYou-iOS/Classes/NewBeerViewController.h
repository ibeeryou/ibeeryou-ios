//
//  NewBeerViewController.h
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface NewBeerViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIPickerView *userPicker;

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) PFUser *selected_user;

- (void)addButtonTouchHandler:(id)sender;
- (void)cancelButtonTouchHandler:(id)sender;

@end

