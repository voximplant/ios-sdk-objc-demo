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


@interface ACMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UITextField *contactUsernameField;
@property (strong, nonatomic) NSString *endpointUsername;
@property (strong, atomic) ACUser *loggedInUser;


@end

@implementation ACMainViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegateMacros.sharedCallManager.delegate = self;
    self.loggedInUser = [ACUser userWithUsername:AppDelegateMacros.sharedAuthService.lastLoggedInUser.username
                                   displayName:AppDelegateMacros.sharedAuthService.lastLoggedInUser.displayName];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.callButton setEnabled:YES];
}

- (void)setupUI {
    self.navigationItem.titleView = VoxBranding.logoView;

    self.userDisplayNameLabel.text = [NSString stringWithFormat:@"Logged in as %@", self.loggedInUser.displayName];

    [self hideKeyboardWhenTappedAround];
}

#pragma mark - Actions
- (IBAction)logoutTouch:(UIBarButtonItem *)sender {
    NSLog(@"logoutTouch called on MainViewController");
    [AppDelegateMacros.sharedAuthService disconnect:^(void) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)callTouch:(UIButton *)sender {
    NSLog(@"Calling from MainViewController");
    if (AVAudioSession.sharedInstance.recordPermission != AVAudioSessionRecordPermissionGranted) {
        [AVAudioSession.sharedInstance requestRecordPermission:^(BOOL granted) {
            if (granted) {
                [self startCall];
            } else {
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"Settings"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   if (@available(iOS 10.0, *)) {
                                                                       [[UIApplication sharedApplication] openURL:([NSURL URLWithString:UIApplicationOpenSettingsURLString])
                                                                                                          options:@{}
                                                                                                completionHandler:nil];
                                                                   } else {
                                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                   }
                                                               }];
                [UIHelper showError:@"Audio permission required" action:action controller:nil];
            }
        }];
    } else {
        [self startCall];
    }
}

- (void)startCall {
    __weak ACMainViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppDelegateMacros.sharedCallManager startOutgoingCallWithContact:self.contactUsernameField.text completion:^(NSError * _Nullable error) {
            if (error) {
                [UIHelper showError:error.localizedDescription action:nil controller:nil];
            } else {
                __strong ACMainViewController *strongSelf = weakSelf;
                [strongSelf prepareUIToCall];
                strongSelf.endpointUsername = strongSelf.contactUsernameField.text;
                [strongSelf performSegueWithIdentifier:NSStringFromClass([ACCallViewController class]) sender:strongSelf];
            }
        }];
    });
}

#pragma mark - Call
- (void)prepareUIToCall {
    [self.callButton setEnabled:NO];
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ACCallViewController class]]) {
        ACCallViewController *callViewController = segue.destinationViewController;
        callViewController.endpointUsername = self.endpointUsername;
    }
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue {
}

- (void)reconnect {
    NSLog(@"reconnect called on MainViewController");

    [UIHelper showProgressWithTitle:@"Reconnecting" details:@"Please wait..." controller:self];

    NSString *username = [self.loggedInUser.username stringByAppendingString:@".voximplant.com"];
    __weak ACMainViewController *weakSelf = self;

    [AppDelegateMacros.sharedAuthService loginUsingTokenWithUser:username
                                   completion:^(NSString * _Nullable userDisplayName, NSError * _Nullable error) {
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
