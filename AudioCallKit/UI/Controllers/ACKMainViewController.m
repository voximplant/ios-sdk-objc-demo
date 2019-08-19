/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKMainViewController.h"
#import "ACKCallViewController.h"
#import "VoxBranding.h"
#import "UIExtensions.h"
#import "UIHelper.h"
#import "ACKAppDelegate.h"
#import "VoxPermissionsManager.h"


@interface ACKMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UITextField *contactUsernameField;
@property (strong, atomic) VoxUser *loggedInUser;
@property (strong, nonatomic) CXCallController *callController;

@end


@implementation ACKMainViewController

- (CXCallController *)callController {
    return AppDelegateMacros.sharedCallController;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loggedInUser = [VoxUser userWithUsername:AppDelegateMacros.sharedAuthService.lastLoggedInUser.username
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
    [AppDelegateMacros.sharedAuthService logout:^(void) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)callTouch:(UIButton *)sender {
    NSLog(@"Calling from MainViewController");
    
    __weak ACKMainViewController *weakSelf = self;
    [VoxPermissionsManager checkAudioPermission:^{
        __strong ACKMainViewController *strongSelf = weakSelf;
        CXStartCallAction *startOutgoingCall = [[CXStartCallAction alloc] initWithCallUUID:[[NSUUID alloc] init]
                                                                                    handle:[[CXHandle alloc] initWithType:CXHandleTypeGeneric
                                                                                                                    value:strongSelf.contactUsernameField.text]];
        if (@available(iOS 11.0, *)) {
            [strongSelf.callController requestTransactionWithAction:startOutgoingCall
                                                   completion:^(NSError * _Nullable error) {
                                                       if (error) {
                                                           NSLog(@"%@", error.localizedDescription);
                                                           [UIHelper showError:error.localizedDescription action:nil controller:nil];
                                                       }
                                                   }];
        } else {
            [strongSelf.callController requestTransaction:[[CXTransaction alloc] initWithAction:startOutgoingCall]
                                         completion:^(NSError * _Nullable error) {
                                             if (error) {
                                                 NSLog(@"%@", error.localizedDescription);
                                                 [UIHelper showError:error.localizedDescription action:nil controller:nil];
                                             }
            }];
        }
    }];
}

- (void)prepareUIToCall {
    [self.callButton setEnabled:NO];
    [self.view endEditing:YES];
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue {
}

- (void)reconnect {
    NSLog(@"reconnect called on MainViewController");
    
    [UIHelper showProgressWithTitle:@"Reconnecting" details:@"Please wait..." controller:self];
    
    NSString *username = self.loggedInUser.username;
    __weak ACKMainViewController *weakSelf = self;
    
    [AppDelegateMacros.sharedAuthService loginUsingTokenWithUser:username
                                                      completion:^(NSString * _Nullable userDisplayName, NSError * _Nullable error) {
                                                          __strong ACKMainViewController *strongSelf = weakSelf;
                                                          if (error) {
                                                              [UIHelper showError:error.localizedDescription action:nil controller:strongSelf];
                                                          } else {
                                                              strongSelf.userDisplayNameLabel.text = [NSString stringWithFormat:@"Logged in as %@", userDisplayName];
                                                          }
                                                          [UIHelper hideProgressOnViewController:strongSelf];
                                                      }];
}

#pragma mark - AppLifeCycleDelegate
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self reconnect];
}

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    if (call.hasConnected) {
        [self performSegueWithIdentifier:NSStringFromClass([ACKCallViewController class]) sender:self];
    }
}

@end
