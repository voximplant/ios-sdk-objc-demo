/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface UIImage (ImageWithInsets)

- (UIImage*)imageWithInsets:(UIEdgeInsets)insets;

@end


@interface UIViewController (HideKeyboardWhenTappedAround)

- (void)hideKeyboardWhenTappedAround;

- (void)dismissKeyboard;

@end

@interface UIViewController (ToppestViewController)

@property (strong, nonatomic, readonly) UIViewController *topPresentedController;
@property (strong, nonatomic, readonly) UIViewController *toppestViewController;

@end



