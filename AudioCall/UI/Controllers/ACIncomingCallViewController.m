/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACIncomingCallViewController.h"
#import "ACCallManager.h"
#import "ACMainViewController.h"
#import "ACAppDelegate.h"
#import "VoxPermissionsManager.h"



@interface ACIncomingCallViewController ()

@property (weak, nonatomic) IBOutlet UILabel *endpointDisplayNameLabel;
@property (strong, nonatomic) VICall *call;

@end

@implementation ACIncomingCallViewController

- (VICall *)call {
    return AppDelegateMacros.sharedCallManager.managedCall;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.call addDelegate:self]; // add call delegate to current call
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.endpointDisplayNameLabel.text = self.call.endpoints.firstObject.userDisplayName;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) { return UIStatusBarStyleDarkContent; }
    else { return UIStatusBarStyleDefault; }
}

- (IBAction)declineTouch:(UIButton *)sender {
    NSLog(@"declineTouch called on IncomingCallViewController");
    [self.call rejectWithMode:VIRejectModeDecline headers:nil]; // decline call
}

- (IBAction)acceptTouch:(UIButton *)sender {
    NSLog(@"acceptTouch called on IncomingCallViewController");
    [VoxPermissionsManager checkAudioPermission:^{
        [AppDelegateMacros.sharedCallManager makeIncomingCallActive]; // answer call
        [self.call removeDelegate:self];
    }];
}

- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    [self.call removeDelegate:self];
    [self performSegueWithIdentifier:NSStringFromClass([ACMainViewController class]) sender:self];
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    [self.call removeDelegate:self];
    [self performSegueWithIdentifier:NSStringFromClass([ACMainViewController class]) sender:self];
}

@end
