/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACCallFailedViewController.h"

@interface ACCallFailedViewController ()

@property (weak, nonatomic) IBOutlet UILabel *endpointDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *failReasonLabel;

@end

@implementation ACCallFailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.failReasonLabel.text = self.failingReason;
    self.endpointDisplayNameLabel.text = self.endpointDisplayName;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
