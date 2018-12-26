/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "QIAppDelegate.h"
#import "QILoginViewController.h"
#import "QIDialerViewController.h"

@import VoxImplant;

@interface QILoginViewController () <QIVoxClientManagerListener>

@end

@implementation QILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    self.sdkLabel.text = [NSString stringWithFormat:@"%@ v%@", self.sdkLabel.text, [VIClient clientVersion]];
    self.rtcLabel.text = [NSString stringWithFormat:@"%@ v%@", self.rtcLabel.text, [VIClient webrtcVersion]];

    self.loginField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"QILogin"];

    [[QIAppDelegate instance].voxManager addListener:self];
}

- (IBAction)loginTouched:(UIButton *)sender {
    NSString *login = self.loginField.text;
    [[NSUserDefaults standardUserDefaults] setObject:login forKey:@"QILogin"];
    if (![login hasSuffix:@".voximplant.com"]) {
        login = [login stringByAppendingString:@".voximplant.com"];
    }
    [[QIAppDelegate instance].voxManager loginWithUsername:login
                                               andPassword:self.passwordField.text];
}

- (void)loginDidSucceedWithName:(NSString *)displayName {
    [self performSegueWithIdentifier:@"ShowDialer" sender:displayName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QIDialerViewController *vc = segue.destinationViewController;
    vc.title = sender;
}

- (void)loginDidFailWithError:(NSError *)error {
    [[QIAppDelegate instance] showError:error];
}

@end
