/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "QSViewController.h"

#error Enter Voximplant account credentials
static NSString *const kUsername = @"user@app.acc.voximplant.com";
static NSString *const kPassword = @"p@ssw0rd";

@import VoxImplant;

@interface QSViewController () <VIClientSessionDelegate, VIClientCallManagerDelegate, VICallDelegate>

@property (strong, nonatomic) VIClient *client;
@property (strong, nonatomic) VICall *currentCall;

@end

@implementation QSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [VIClient setLogLevel:VILogLevelInfo];
    _client = [[VIClient alloc] initWithDelegateQueue:dispatch_get_main_queue()];
    _client.sessionDelegate = self;
    _client.callManagerDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [_client connect];
}

- (void)callButtonTouched:(id)sender {
    if (_currentCall) {
        [self endCall];
    } else {
        [self call];
    }
}

- (void)call {
    if (!_currentCall) {
        VICallSettings *callSettings = [VICallSettings new];
        callSettings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo:NO];

        _currentCall = [_client call:@"*" settings:callSettings];

        if (_currentCall) {
            [_currentCall addDelegate:self];

            [_currentCall start];
        }
    }
}

- (void)endCall {
    if (_currentCall) {
        [_currentCall hangupWithHeaders:nil];
    }
}

#pragma mark - VIClientSessionDelegate
- (void)clientSessionDidConnect:(VIClient *)client {
    NSLog(@"Connection established");
    [_client loginWithUser:kUsername password:kPassword success:^(NSString * _Nonnull displayName, NSDictionary * _Nonnull authParams) {
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"Login failed: %@", error.localizedDescription);
    }];
}

- (void)clientSessionDidDisconnect:(VIClient *)client {
    NSLog(@"Connection closed");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callButton.selected = NO;
    });
}

- (void)client:(VIClient *)client sessionDidFailConnectWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", error.localizedDescription);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callButton.selected = NO;
    });
}

#pragma mark - VIClientCallManagerDelegate

- (void)client:(VIClient *)client didReceiveIncomingCall:(VICall *)call withIncomingVideo:(BOOL)video headers:(nullable NSDictionary *)headers {
    if (_currentCall) {
        [call rejectWithMode:VIRejectModeBusy headers:nil];
        return;
    }
    _currentCall = call;
    [_currentCall addDelegate:self];

    VICallSettings *callSettings = [VICallSettings new];
    callSettings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo:NO];
    [_currentCall answerWithSettings:callSettings];
}

#pragma mark - VICallDelegate

- (void)call:(VICall *)call didConnectWithHeaders:(NSDictionary *)headers {
    NSLog(@"You can hear audio from the cloud");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callButton.selected = YES;
    });
}

- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    NSLog(@"The call has ended");
    [call removeDelegate:self];
    _currentCall = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callButton.selected = NO;
    });
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    NSLog(@"Call failed with error: %@", error.localizedDescription);
    [call removeDelegate:self];
    _currentCall = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callButton.selected = NO;
    });
}

@end
