/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACCallViewController.h"
#import "VoxLabelWithTimer.h"
#import "VoxButtonWithLabel.h"
#import "VoxKeyPadView.h"
#import "ACCallFailedViewController.h"
#import "ACMainViewController.h"
#import "ACCallManager.h"
#import "UIHelper.h"
#import "ACAppDelegate.h"
#import "UIExtensions.h"
#import "VoxUser.h"

@interface VoxLabelWithTimer (UpdateCallStatus)

- (void)updateCallStatusWithTime:(NSTimeInterval)time;

@end


@interface ACCallViewController ()

@property (weak, nonatomic) IBOutlet UILabel *endpointDisplayNameLabel;
@property (weak, nonatomic) IBOutlet VoxLabelWithTimer *callStateLabel;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *holdButton;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *muteButton;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *speakerButton;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *dtmfButton;
@property (weak, nonatomic) IBOutlet VoxKeyPadView *keyPadView;
@property (nonatomic) BOOL isMuted;
@property (strong, nonatomic) VICall *call;
@property (strong, nonatomic) NSSet<VIAudioDevice *> *audioDevices;
@property (strong, nonatomic) NSString *reasonToFail;
@property (strong, nonatomic) VoxUser *endpoint;
@property (strong, nonatomic) ACCallManager *callManager;

@end


@implementation ACCallViewController

- (ACCallManager *)callManager {
    return AppDelegateMacros.sharedCallManager;
}

- (VICall *)call { //returns current call
    return self.callManager.managedCall;
}

- (NSSet<VIAudioDevice *> *)audioDevices {
    return [VIAudioManager.sharedAudioManager availableAudioDevices];
}

- (void)setIsMuted:(BOOL)isMuted {
    [self.muteButton setSelected:isMuted];
    self.muteButton.label.text = isMuted ? @"unmute": @"mute";
    [self.call setSendAudio:!isMuted];
    _isMuted = isMuted;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.endpoint = [VoxUser userWithUsername:@"" displayName:@""];
    self.endpoint.username = self.callManager.managedCall.endpoints.firstObject.user;
    self.endpointDisplayNameLabel.text = self.endpoint.username;
    self.isMuted = NO;
    [self setupDelegates];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) { return UIStatusBarStyleDarkContent; }
    else { return UIStatusBarStyleDefault; }
}

- (void)setupDelegates {
    [self.call addDelegate:self];
    VIAudioManager.sharedAudioManager.delegate = self;
}

#pragma mark - Actions
- (IBAction)muteTouch:(VoxButtonWithLabel *)sender {
    NSLog(@"MuteTouch called on CallViewController");
    [self setIsMuted:!self.isMuted];
}

- (IBAction)dtmfTouch:(VoxButtonWithLabel *)sender {
    self.endpointDisplayNameLabel.text = @" "; //clear label to show numbers
    [self.keyPadView setHidden:NO];
}

- (IBAction)audioDeviceTouch:(VoxButtonWithLabel *)sender {
    [self showAudioDevices];
}

- (IBAction)holdTouch:(VoxButtonWithLabel *)sender {
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
    NSLog(@"Calling %@ from CallViewController", self.endpoint.username);
    [self.callManager startOutgoingCallWithContact:self.endpoint.username completion:^(NSError * _Nullable error) {
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
        if (![self.endpoint.displayName isEqual: @""]) {
            callFailedController.endpointDisplayName = self.endpoint.displayName;
        } else {
            callFailedController.endpointDisplayName = self.endpoint.username;
        }
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
    
    NSString *username = call.endpoints.firstObject.user;
    NSString *displayName = call.endpoints.firstObject.userDisplayName;
    
    if (username && displayName) {
        self.endpoint.username = username;
        self.endpoint.displayName = displayName;
    }
    self.endpointDisplayNameLabel.text = self.endpoint.displayName;

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

- (void)showAudioDevices {
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
    self.endpointDisplayNameLabel.text = self.endpoint.displayName;
}

#pragma mark - Timer Delegate
- (void)updateTime { [self.callStateLabel updateCallStatusWithTime:self.call.duration]; }

@end

@implementation VoxLabelWithTimer (UpdateCallStatus)

- (void)updateCallStatusWithTime:(NSTimeInterval)time {
    if (time) {
        NSString *text = [self buildStringTimeToDisplayWithTime:time];
        self.text = [NSString stringWithFormat:@"%@ - Call in progress", text];
    } else {
        self.text = @"Call in progress";
    }
}

@end
