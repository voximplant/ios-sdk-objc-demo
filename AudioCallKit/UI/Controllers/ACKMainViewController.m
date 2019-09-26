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
@property (strong, nonatomic, readonly) CXCallController *callController;
@property (strong, nonatomic, readonly) ACKAuthService *authService;

@end


@implementation ACKMainViewController

- (CXCallController *)callController { return AppDelegateMacros.sharedCallController; }
- (ACKAuthService *)authService { return AppDelegateMacros.sharedAuthService; }

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

#pragma mark - Setup User Interface
- (void)setupUI {
    self.navigationItem.titleView = VoxBranding.logoView;
    [self hideKeyboardWhenTappedAround];
}

- (void)showSelfDisplayName {
    NSString *displayName = self.authService.loggedInUserDisplayName;
    if (displayName) {
        self.userDisplayNameLabel.text = [NSString stringWithFormat:@"Logged in as %@", displayName];
    }
}

#pragma mark - Actions
- (IBAction)logoutTouch:(UIBarButtonItem *)sender {
    NSLog(@"logoutTouch called on MainViewController");
    [self.authService logout:^(void) { [self.navigationController popViewControllerAnimated:YES]; }];
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
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
        else { [strongSelf.callController requestTransaction:[[CXTransaction alloc] initWithAction:startOutgoingCall]
                                                  completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
    }];
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue {
}

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    __weak ACKMainViewController *weakSelf = self;
    [self performSegueWithIdentifier:NSStringFromClass([ACKCallViewController class]) sender:self completion:^{
        __strong ACKMainViewController *strongSelf = weakSelf;
        ACKCallViewController *callController = (ACKCallViewController *)strongSelf.parentViewController.toppestViewController;
        [callController callObserver:callObserver callChanged:call];
    }];
}

@end
