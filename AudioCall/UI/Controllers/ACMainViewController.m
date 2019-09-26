/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACMainViewController.h"
#import "ACCallViewController.h"
#import "VoxBranding.h"
#import "ACAuthService.h"
#import "ACCallManager.h"
#import "ACIncomingCallViewController.h"
#import "UIExtensions.h"
#import "UIHelper.h"
#import "ACAppDelegate.h"
#import "VoxPermissionsManager.h"


@interface ACMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UITextField *contactUsernameField;
@property (strong, nonatomic, readonly) ACAuthService *authService;

@end

@implementation ACMainViewController

- (ACAuthService *)authService { return AppDelegateMacros.sharedAuthService; }

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showSelfDisplayName];
    [self.callButton setEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showSelfDisplayName];
}

- (void)showSelfDisplayName {
    NSString *displayName = self.authService.loggedInUserDisplayName;
    if (displayName) {
        self.userDisplayNameLabel.text = [NSString stringWithFormat:@"Logged in as %@", displayName];
    }
}

- (void)setupUI {
    self.navigationItem.titleView = VoxBranding.logoView;
    [self hideKeyboardWhenTappedAround];
}

#pragma mark - Actions
- (IBAction)logoutTouch:(UIBarButtonItem *)sender {
    NSLog(@"logoutTouch called on MainViewController");
    [AppDelegateMacros.sharedAuthService logout:^(void) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)callTouch:(UIButton *)sender {
    NSLog(@"Calling from MainViewController");
    
    __weak ACMainViewController *weakSelf = self;
    [VoxPermissionsManager checkAudioPermission:^{
        [AppDelegateMacros.sharedCallManager startOutgoingCallWithContact:self.contactUsernameField.text completion:^(NSError * _Nullable error) {
            if (error) {
                [UIHelper showError:error.localizedDescription action:nil controller:nil];
            } else {
                __strong ACMainViewController *strongSelf = weakSelf;
                [strongSelf prepareUIToCall];
                [strongSelf performSegueWithIdentifier:NSStringFromClass([ACCallViewController class]) sender:strongSelf];
            }
        }];
    }];
}

- (void)prepareUIToCall {
    [self.callButton setEnabled:NO];
    [self.view endEditing:YES];
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue {
}

- (IBAction)unwindToIncomingCall:(UIStoryboardSegue *)unwindSegue {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:NSStringFromClass([ACIncomingCallViewController class]) sender:self];
    });
}

- (void)reconnect {
    NSLog(@"reconnect called on MainViewController");

    [UIHelper showProgressWithTitle:@"Reconnecting" details:@"Please wait..." controller:self];
    
    __weak ACMainViewController *weakSelf = self;
    
    [AppDelegateMacros.sharedAuthService loginUsingTokenWithCompletion:^(NSString * _Nullable userDisplayName, NSError * _Nullable error) {
        __strong ACMainViewController *strongSelf = weakSelf;
        if (error) {
            [UIHelper showError:error.localizedDescription action:nil controller:strongSelf];
        } else {
            strongSelf.userDisplayNameLabel.text = [NSString stringWithFormat:@"Logged in as %@", userDisplayName];
        }
        [UIHelper hideProgressOnViewController:strongSelf];
    }];
}


- (void)notifyIncomingCall:(nonnull VICall *)descriptor {
    [self performSegueWithIdentifier:NSStringFromClass([ACIncomingCallViewController class]) sender:self];
}

@end
