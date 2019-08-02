/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACCustomTextField : UITextField

@property (weak, nonatomic) IBOutlet UIView *rightSideView;

- (IBAction)nextField:(UITextField *)sender;

@end

NS_ASSUME_NONNULL_END
