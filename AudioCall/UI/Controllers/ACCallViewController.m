/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACCallViewController.h"
#import "ACLabelWithTimer.h"
#import "ACButtonWithLabel.h"
#import "ACKeyPadView.h"
#import "ACCallFailedViewController.h"
#import "ACMainViewController.h"
#import "ACCallManager.h"
#import "UIHelper.h"
#import "ACAppDelegate.h"
#import "UIExtensions.h"


@interface UIViewController (ConvertTimeToString)

+ (NSString *)convertTimeToString:(NSTimeInterval)time;

@end


@interface ACCallViewController ()

@property (weak, nonatomic) IBOutlet UILabel *endpointDisplayNameLabel;
@property (weak, nonatomic) IBOutlet ACLabelWithTimer *callStateLabel;
@property (weak, nonatomic) IBOutlet ACButtonWithLabel *holdButton;
@property (weak, nonatomic) IBOutlet ACButtonWithLabel *muteButton;
@property (weak, nonatomic) IBOutlet ACButtonWithLabel *speakerButton;
@property (weak, nonatomic) IBOutlet ACButtonWithLabel *dtmfButton;
@property (weak, nonatomic) IBOutlet ACKeyPadView *keyPadView;
@property (nonatomic) BOOL isMuted;
@property (strong, nonatomic) VICall *call;
@property (strong, nonatomic) NSSet<VIAudioDevice *> *audioDevices;
@property (strong, nonatomic) NSString *endpointDisplayName;
@property (strong, nonatomic) NSString *reasonToFail;

@end



@implementation ACCallViewController

- (VICall *)call {
    return AppDelegateMacros.sharedCallManager.managedCall;
}

- (NSSet<VIAudioDevice *> *)audioDevices {
    return [VIAudioManager.sharedAudioManager availableAudioDevices];
}

- (NSString *)endpointDisplayName {
    NSString *name = AppDelegateMacros.sharedCallManager.managedCall.endpoints.firstObject.userDisplayName;
    if (name) {
        return name;
    } else {
        return self.endpointUsername;
    }
}

- (void)setMuted:(BOOL)isMuted {
    [self.muteButton setSelected:isMuted];
    self.muteButton.label.text = isMuted ? @"unmute": @"mute";
    [self.call setSendAudio:!isMuted];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupDelegates];
    self.endpointDisplayNameLabel.text = self.endpointDisplayName;
    self.isMuted = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)setupDelegates {
    [self.call addDelegate:self];
    VIAudioManager.sharedAudioManager.delegate = self;
}

#pragma mark - Actions
- (IBAction)muteTouch:(ACButtonWithLabel *)sender {
    NSLog(@"MuteTouch called on CallViewController");
    self.isMuted = !self.isMuted;
    [self setMuted:self.isMuted];
}

- (IBAction)dtmfTouch:(ACButtonWithLabel *)sender {
    self.endpointDisplayNameLabel.text = @" "; //clear label to show numbers
    [self.keyPadView setHidden:NO];
}

- (IBAction)audioDeviceTouch:(ACButtonWithLabel *)sender {
    [self showAudioDevices];
}

- (IBAction)holdTouch:(ACButtonWithLabel *)sender {
    __weak ACCallViewController *weakSelf = self;

    [sender setEnabled:NO];
    [self.call setHold:!sender.isSelected completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"setHold: %@", error.localizedDescription);
            [UIHelper showError:error.localizedDescription action:nil controller:nil];
            [sender setEnabled:YES];
        } else {
            NSLog(@"SetHold: no errors");
            __strong ACCallViewController *strongSelf = weakSelf;
            if (sender.isSelected) {
                strongSelf.holdButton.label.text = @"hold";
                [strongSelf.holdButton setImage:[UIImage imageNamed:@"hold"] forState: UIControlStateNormal];
            } else {
                strongSelf.holdButton.label.text = @"resume";
                [strongSelf.holdButton setImage:[UIImage imageNamed:@"resumeP"] forState:UIControlStateNormal];
            }
            [sender setSelected:!sender.isSelected];
            [sender setEnabled:YES];
        }
    }];
}

- (IBAction)hangupTouch:(UIButton *)sender {
    NSLog(@"hangupTouch called on CallViewController");
    [self.call hangupWithHeaders:nil];
}

- (IBAction)unwindToCall:(UIStoryboardSegue *)unwindSegue {
    NSLog(@"Calling %@ from CallViewController", self.endpointUsername);
    [AppDelegateMacros.sharedCallManager startOutgoingCallWithContact:self.endpointUsername completion:^(NSError * _Nullable error) {
        if (error) {
            [self dismissViewControllerAnimated:NO completion:^{
                [UIHelper showError:error.localizedDescription action:nil controller:AppDelegateMacros.window.rootViewController];
            }];
        } else {
            [self setupDelegates];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ACCallFailedViewController class]]) {
        ACCallFailedViewController *callFailedController = segue.destinationViewController;
        callFailedController.endpointDisplayName = self.endpointDisplayName;
        callFailedController.failingReason = self.reasonToFail;
    }
}

#pragma mark - VICallDelegate
- (void)call:(VICall *)call startRingingWithHeaders:(NSDictionary *)headers {
    NSLog(@"startRingingWithHeaders called on CallViewController");
    self.callStateLabel.text = @"Ringing";
}

- (void)call:(VICall *)call didConnectWithHeaders:(NSDictionary *)headers {
     NSLog(@"didConnectWithHeaders called on CallViewController");
    self.endpointUsername = AppDelegateMacros.sharedCallManager.managedCall.endpoints.firstObject.user;
    self.endpointDisplayNameLabel.text = call.endpoints.firstObject.userDisplayName;

    [self.dtmfButton setEnabled:YES]; // show call duration and unblock buttons
    [self.holdButton setEnabled:YES];

    [self.callStateLabel runTimer];
}

- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
     NSLog(@"didDisconnectWithHeaders called on CallViewController");
    [self.call removeDelegate:self];
    [self performSegueWithIdentifier:NSStringFromClass([ACMainViewController class]) sender:self];
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
     NSLog(@"didFailWithError called on CallViewController");
    [self.call removeDelegate:self];
    if (error.code == VICallFailErrorCodeInvalidNumber) {
        [self dismissViewControllerAnimated:NO completion:^{
            [UIHelper showError:error.localizedDescription action:nil controller:nil];
        }];
    } else {
        self.reasonToFail = error.localizedDescription;
        [self performSegueWithIdentifier:NSStringFromClass([ACCallFailedViewController class]) sender:self];
    }
}

#pragma mark - Audio Manager Delegate Methods && Functional
- (void)audioDeviceChanged:(VIAudioDevice *)audioDevice {
    NSLog(@"audioDeviceBecomeDefault: %@", audioDevice);
    switch (audioDevice.type) {
        case VIAudioDeviceTypeReceiver:
            [self changeAudioDeviceButtonState:NO image:[UIImage imageNamed:@"speakerP"]];
            break;
        case VIAudioDeviceTypeSpeaker:
            [self changeAudioDeviceButtonState:YES image:[UIImage imageNamed:@"speakerP"]];
            break;
        case VIAudioDeviceTypeWired:
            [self changeAudioDeviceButtonState:YES image:[UIImage imageNamed:@"speakerW"]];
            break;
        case VIAudioDeviceTypeBluetooth:
            [self changeAudioDeviceButtonState:YES image:[UIImage imageNamed:@"speakerBT"]];
            break;
        default:
            [self changeAudioDeviceButtonState:NO image:[UIImage imageNamed:@"speakerP"]];
            break;
    }
}

- (void)audioDeviceUnavailable:(VIAudioDevice *)audioDevice {
    NSLog(@"audioDeviceUnavailable: %@", audioDevice);
}

- (void)audioDevicesListChanged:(NSSet<VIAudioDevice *> *)availableAudioDevices {
    NSLog(@"audioDevicesListChanged: %@", availableAudioDevices);
}

-(void)showAudioDevices {
    UIAlertController *alertSheet = [UIAlertController alertControllerWithTitle:nil
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    for (VIAudioDevice *device in self.audioDevices) {
        [alertSheet addAction:[UIAlertAction actionWithTitle:[self generateDeviceTitleForDevice:device]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [VIAudioManager.sharedAudioManager selectAudioDevice:device];
                                                     }]];
    }

    [alertSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertSheet animated:YES completion:nil];
}

- (NSString *)generateDeviceTitleForDevice:(VIAudioDevice *)device {
    NSString *deviceString = device.description;
    NSString *clearDeviceName = [deviceString stringByReplacingOccurrencesOfString:@"VIAudioDevice" withString:@""];
    return clearDeviceName;
}

- (void)changeAudioDeviceButtonState:(BOOL)isSelected image:(UIImage *)image {
    [self.speakerButton setImage:image forState:UIControlStateSelected];
    [self.speakerButton setSelected:isSelected];
}

#pragma mark - Key Pad Delegate Methods
- (void)DTMFButtonTouched:(NSString *)symbol {
    NSLog(@"DTMF code sent: %@", symbol);
    self.endpointDisplayNameLabel.text = [self.endpointDisplayNameLabel.text stringByAppendingString:symbol]; // saves all buttons touched in dtmf to label
    [self.call sendDTMF:symbol];
}

- (void)keypadDidHide {
    self.endpointDisplayNameLabel.text = self.endpointDisplayName;
}

#pragma mark - Timer Delegate
- (void)updateTime {
    NSString *time;
    NSString *timeString = [UIViewController convertTimeToString:self.call.duration];
    if (self.call.duration) {
        time = [timeString stringByAppendingString:@" - "];
    } else {
        time = @"";
    }
    self.callStateLabel.text = [time stringByAppendingString:@"Call in progress"];
}

@end


@implementation UIViewController (ConvertTimeToString)

+ (NSString *)convertTimeToString:(NSTimeInterval)time {
    int minutes = (int)time / 60 % 60;
    int seconds = (int)time % 60;
    return [NSString stringWithFormat:@"%02i:%02i",minutes,seconds];
}

@end
