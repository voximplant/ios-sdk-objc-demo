/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACCallFailedViewController.h"
#import "ACMainViewController.h"

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
    if (@available(iOS 13.0, *)) { return UIStatusBarStyleDarkContent; }
    else { return UIStatusBarStyleDefault; }
}

- (void)notifyIncomingCall:(VICall *)descriptor {
    [self performSegueWithIdentifier:NSStringFromClass([ACMainViewController class]) sender:self];
}

@end
