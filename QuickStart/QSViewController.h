/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface QSViewController : UIViewController

@property(strong, nonatomic) IBOutlet UIButton *callButton;

- (IBAction)callButtonTouched:(id)sender;

@end

