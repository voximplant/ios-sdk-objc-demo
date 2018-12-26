/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIDialerViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *contactField;
@property (strong, nonatomic) IBOutlet UIButton *callButton;

- (IBAction)callTouched:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
