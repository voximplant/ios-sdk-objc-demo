/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "QIAppDelegate.h"
#import "QIDialerViewController.h"
#import "QICallViewController.h"

@interface QIDialerViewController () <QIVoxClientManagerListener>

@end

@implementation QIDialerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[QIAppDelegate instance].voxManager addListener:self];
}

- (void)callTouched:(UIButton *)sender {
    VIVideoFlags *videoFlags = [VIVideoFlags defaultVideoFlags];
    
    VICall *call = [[QIAppDelegate instance].voxManager createCall:self.contactField.text
                                     withVideoFlags:videoFlags
                                                        conference:NO];
    [self showCallViewController:^(QICallViewController *vc) {
        vc.currentCall = call;
        [call start];
    }];
}

- (void)callConferenceTouched:(UIButton *)sender {
    VIVideoFlags *videoFlags = [VIVideoFlags defaultVideoFlags];

    VICall *callConference = [[QIAppDelegate instance].voxManager createCall:self.contactField.text
                                                              withVideoFlags:videoFlags
                                                                  conference:YES];
    [self showCallViewController:^(QICallViewController *vc) {
        vc.currentCall = callConference;
        [callConference start];
    }];
}

- (void)incomingCallReceived:(VICall *)call withVideoFlags:(VIVideoFlags *)videoFlags {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call"
                                                                   message:call.endpoints.firstObject.userDisplayName
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [call rejectWithMode:VIRejectModeDecline headers:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showCallViewController:^(QICallViewController *vc){
            vc.currentCall = call;

            VICallSettings *settings = [VICallSettings new];
            settings.videoFlags = videoFlags;
            
            [call answerWithSettings:settings];
        }];
    }]];

    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)showCallViewController:(void(^)(QICallViewController *vc))completion {
    [self performSegueWithIdentifier:@"ShowCall" sender:completion];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    void(^completion)(QICallViewController *vc) = sender;
    completion(segue.destinationViewController);
}

@end
