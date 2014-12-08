//
//  NewBeerViewController.h
//  IBeerYou-iOS
//
//  Created by Jean Loup Yu on 08/12/14.
//
//

#import <UIKit/UIKit.h>

@interface NewBeerViewController : UIViewController

@property (nonatomic, strong) UITextView *textView;

- (void)addButtonTouchHandler:(id)sender;
- (void)cancelButtonTouchHandler:(id)sender;

@end

