/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKLoginViewController.h"
#import "VoxBranding.h"
#import "ACKMainViewController.h"
#import "VoxTextField.h"
#import "ACKAppDelegate.h"
#import "UIExtensions.h"
#import "UIHelper.h"

@interface ACKLoginViewController ()

@property (weak, nonatomic) IBOutlet VoxTextField *loginUserField;
@property (weak, nonatomic) IBOutlet VoxTextField *loginPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIView *tokenContainerView;
@property (strong, nonatomic) NSString *tokenExpireDate;
@property (strong, nonatomic) NSString *userDisplayName;

@end


@implementation ACKLoginViewController

- (NSString *)tokenExpireDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [AppDelegateMacros.sharedAuthService possibleToLogin];
    if (date) {
        return [formatter stringFromDate:date];
    }
    return nil;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshUI];
}

#pragma mark - UI methods
- (void)setupUI {
    self.navigationItem.titleView = VoxBranding.logoView;
    self.versionLabel.text = [[NSString alloc] initWithFormat:@"VoximplantSDK %@\nWebRTC %@",
                              VIClient.clientVersion,
                              VIClient.webrtcVersion];
    [self hideKeyboardWhenTappedAround];
}

- (void)refreshUI {
    self.loginUserField.text = [AppDelegateMacros.sharedAuthService.lastLoggedInUser.username
                                stringByReplacingOccurrencesOfString:@".voximplant.com" withString:@""];
    
    [self.tokenContainerView setHidden:NO];
    if (!self.tokenExpireDate) {
        [self.tokenContainerView setHidden:YES];
    }
    
    self.tokenLabel.text = [NSString stringWithFormat:@"Token will expire at:\n%@", self.tokenExpireDate];
}

#pragma mark - Actions
- (IBAction)loginTouch:(NSObject *)sender {
    NSLog(@"LoginTouch called on LoginViewController ");
    
    NSString *login = self.loginUserField.textWithVoxDomain;
    NSString *password = self.loginPasswordField.text;
    
    [UIHelper showProgressWithTitle:@"Connecting" details:@"Please wait..." controller:self];
    
    __weak ACKLoginViewController *weakSelf = self;
    
    [AppDelegateMacros.sharedAuthService loginWithUser:login
                                              password:password
                                                result:^(NSString *userDisplayName, NSError *error) {
                                                    
                                                    __strong ACKLoginViewController *strongSelf = weakSelf;
                                                    
                                                    [UIHelper hideProgressOnViewController:strongSelf];
                                                    
                                                    if (error) {
                                                        [UIHelper showError:error.localizedDescription action:nil controller:nil];
                                                    } else {
                                                        [strongSelf refreshUI];
                                                        strongSelf.userDisplayName = userDisplayName;
                                                        [strongSelf performSegueWithIdentifier:NSStringFromClass([ACKMainViewController class]) sender:strongSelf];
                                                    }
                                                }];
}

- (IBAction)loginWithTokenTouch:(UIButton *)sender {
    NSLog(@"loginWithTokenTouch called on CallViewController");
    
    [UIHelper showProgressWithTitle:@"Connecting" details:@"Please wait..." controller:self];
    
    NSString *login = self.loginUserField.textWithVoxDomain;
    __weak ACKLoginViewController *weakSelf = self;
    [AppDelegateMacros.sharedAuthService loginUsingTokenWithUser:login completion:^(NSString * _Nullable userDisplayName, NSError * _Nullable error) {
        
        __strong ACKLoginViewController *strongSelf = weakSelf;
        [UIHelper hideProgressOnViewController:strongSelf];
        [strongSelf refreshUI];
        
        if (error) {
            [UIHelper showError:error.localizedDescription action:nil controller:nil];
        } else {
            strongSelf.userDisplayName = userDisplayName;
            [strongSelf performSegueWithIdentifier:NSStringFromClass([ACKMainViewController class]) sender:strongSelf];
        }
    }];
}

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    [self performSegueWithIdentifier:NSStringFromClass([ACKMainViewController class]) sender:self];
}

@end



@implementation UINavigationController (StatusBarStyle)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return false;
}

@end
