/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKCallViewController.h"
#import "VoxLabelWithTimer.h"
#import "VoxButtonWithLabel.h"
#import "VoxKeyPadView.h"
#import "ACKMainViewController.h"
#import "UIHelper.h"
#import "ACKAppDelegate.h"
#import "VoxEndpointlabel.h"
#import "CXExtensions.h"

@interface VoxLabelWithTimer (UpdateCallStatus)

- (void)updateCallStatusWithTime:(NSTimeInterval)time;

@end


@interface ACKCallViewController ()

@property (weak, nonatomic) IBOutlet VoxEndpointLabel *endpointDisplayNameLabel;
@property (weak, nonatomic) IBOutlet VoxLabelWithTimer *callStateLabel;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *holdButton;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *muteButton;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *speakerButton;
@property (weak, nonatomic) IBOutlet VoxButtonWithLabel *dtmfButton;
@property (weak, nonatomic) IBOutlet VoxKeyPadView *keyPadView;
@property (nonatomic) BOOL isMuted;
@property (strong, nonatomic, nullable) CXCall *call;
@property (strong, nonatomic) CXCallController *callController;
@property (strong, nonatomic) NSSet<VIAudioDevice *> *audioDevices;

@end


@implementation ACKCallViewController

- (CXCallController *)callController {
    return AppDelegateMacros.sharedCallController;
}

- (CXCall *)call {
    return self.callController.callObserver.calls.firstObject;
}

- (NSSet<VIAudioDevice *> *)audioDevices {
    return [VIAudioManager.sharedAudioManager availableAudioDevices];
}

- (void)setIsMuted:(BOOL)isMuted {
    [self.muteButton setSelected:isMuted];
    self.muteButton.label.text = isMuted ? @"unmute": @"mute";
    _isMuted = isMuted;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isMuted = NO;
    VIAudioManager.sharedAudioManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateContent];
}

- (void)updateContent {
    CXCall *call = self.call;                               
    if (call.info) {
        NSString *username = call.info.endpoints.firstObject.user;
        NSString *displayName = call.info.endpoints.firstObject.userDisplayName;
        if (username) {
            if (displayName) {
                self.endpointDisplayNameLabel.user = [VoxUser userWithUsername:username displayName:displayName];
            } else {
                self.endpointDisplayNameLabel.user = [VoxUser userWithUsername:username displayName:username];
            }
        } else {
            self.endpointDisplayNameLabel.user = nil;
        }
        if (call.hasConnected) {
            [self.dtmfButton setEnabled:YES]; // show call duration and unblock buttons
            [self.holdButton setEnabled:YES];
            if (!self.callStateLabel.isTimerRunning) { [self.callStateLabel runTimer]; }
        } else {
            [self.dtmfButton setEnabled:NO];
            [self.holdButton setEnabled:NO];
        }
        if (!call.isOnHold) {
            [self.holdButton setSelected:NO];
            [self.holdButton.label setText:@"hold"];
            [self.holdButton setImage:[UIImage imageNamed:@"hold"] forState:UIControlStateNormal];
        } else {
            [self.holdButton setSelected:YES];
            [self.holdButton.label setText:@"resume"];
            [self.holdButton setImage:[UIImage imageNamed:@"resumeP"] forState:UIControlStateNormal];
        }
        self.isMuted = !call.info.sendAudio;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) { return UIStatusBarStyleDarkContent; }
    else { return UIStatusBarStyleDefault; }
}

#pragma mark - Actions
- (IBAction)muteTouch:(VoxButtonWithLabel *)sender {
    NSLog(@"MuteTouch called on CallViewController");
    if (self.call) {
        [self setIsMuted:!self.isMuted];
        CXSetMutedCallAction *setMute = [[CXSetMutedCallAction alloc] initWithCallUUID:self.call.UUID
                                                                                 muted:self.isMuted];
        if (@available(iOS 11.0, *)) {
            [self.callController requestTransactionWithAction:setMute
                                                   completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
        else { [self.callController requestTransaction:[[CXTransaction alloc] initWithAction:setMute]
                                            completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                   [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
    }
}

- (IBAction)dtmfTouch:(VoxButtonWithLabel *)sender {
    self.endpointDisplayNameLabel.text = @" "; // clear label to show numbers
    [self.keyPadView setHidden:NO]; //show keypad
}

- (IBAction)audioDeviceTouch:(VoxButtonWithLabel *)sender {
    [self showAudioDevices];
}

- (IBAction)holdTouch:(VoxButtonWithLabel *)sender {
    [self.holdButton setEnabled:NO];
    if (self.call) {
        CXSetHeldCallAction *setHeld = [[CXSetHeldCallAction alloc] initWithCallUUID:self.call.UUID
                                                                              onHold:!sender.isSelected];
        if (@available(iOS 11.0, *)) {
            [self.callController requestTransactionWithAction:setHeld
                                                   completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"setHold: %@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
        else { [self.callController requestTransaction:[[CXTransaction alloc] initWithAction:setHeld]
                                         completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"setHold: %@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
    }
}

- (IBAction)hangupTouch:(UIButton *)sender {
    NSLog(@"hangupTouch called on CallViewController");
    [sender setEnabled:NO];
    if (self.call) {
        CXEndCallAction *doEndCall = [[CXEndCallAction alloc] initWithCallUUID:self.call.UUID];
        if (@available(iOS 11.0, *)) {
            [self.callController requestTransactionWithAction:doEndCall
                                                   completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
        else { [self.callController requestTransaction:[[CXTransaction alloc] initWithAction:doEndCall]
                                            completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
    }
}

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    NSLog(@"callObserver called on ACKCallViewController callended %d", call.hasEnded);
    [self updateContent];
    if (call.hasEnded) {

        [self performSegueWithIdentifier:NSStringFromClass([ACKMainViewController class]) sender:self];
    }
}

#pragma mark - VIAudioManagerDelegate
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
    
    if (alertSheet.popoverPresentationController) {
        alertSheet.popoverPresentationController.sourceView = self.speakerButton;
    }
    
    [self presentViewController:alertSheet animated:YES completion:nil]; // show alertsheet with audio devices
}

- (NSString *)generateDeviceTitleForDevice:(VIAudioDevice *)device { // generates fromatted string from VIAudioDevice names
    NSString *deviceString = device.description;
    NSString *clearDeviceName = [deviceString stringByReplacingOccurrencesOfString:@"VIAudioDevice" withString:@""];
    return clearDeviceName;
}

- (void)changeAudioDeviceButtonState:(BOOL)isSelected image:(UIImage *)image {
    [self.speakerButton setImage:image forState:UIControlStateSelected];
    [self.speakerButton setSelected:isSelected];
}

#pragma mark - AppLifeCycleDelegate
- (void)applicationDidBecomeActive:(UIApplication *)application { [self updateContent]; }

#pragma mark - KeyPadDelegate
- (void)DTMFButtonTouched:(NSString *)symbol {
    NSLog(@"DTMF code sent: %@", symbol);
     // replace the endpoint display name with DTMFs sent
    self.endpointDisplayNameLabel.text = [self.endpointDisplayNameLabel.text stringByAppendingString:symbol];
    if (self.call) {
        CXPlayDTMFCallAction *sendDTMF = [[CXPlayDTMFCallAction alloc] initWithCallUUID:self.call.UUID
                                                                                 digits:symbol
                                                                                   type:CXPlayDTMFCallActionTypeSingleTone];
        if (@available(iOS 11.0, *)) {
            [self.callController requestTransactionWithAction:sendDTMF
                                                   completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
        else { [self.callController requestTransaction:[[CXTransaction alloc] initWithAction:sendDTMF]
                                            completion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                    [UIHelper showError:error.localizedDescription action:nil controller:nil]; }
            }]; }
    }
}

- (void)keypadDidHide {
    // show the endpoint display name instead of DTMFs
    [self.endpointDisplayNameLabel updateLabel];
}

#pragma mark - TimerDelegate
- (void)updateTime { [self.callStateLabel updateCallStatusWithTime:self.call.info.duration]; }

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
