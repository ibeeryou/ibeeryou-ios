//
//  NewBeerViewController.h
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//

#import <UIKit/UIKit.h>

@interface NewBeerViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIPickerView *userPicker;

@property (nonatomic, strong) NSArray *users;

@property (nonatomic, strong) NSString *selectedUser;

- (void)addButtonTouchHandler:(id)sender;
- (void)cancelButtonTouchHandler:(id)sender;

@end

