/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKCallManager.h"
#import "VoxErrors.h"
#import "ACKPushCallNotifier.h"
#import "CXExtensions.h"

@interface ACKCallManager ()

@property (strong, nonatomic, nonnull) VIClient *client;
@property (strong, nonatomic, nonnull) ACKAuthService *authService;
@property (strong, nonatomic, nonnull) ACKPushCallNotifier *pushCallNotifier;
@property (strong, nonatomic, nonnull) CXProvider *callProvider;

@end


@implementation ACKCallManager

// Voximplant SDK supports multiple calls at the same time, however
// this demo app demonstrates only one managed call at the moment,
// so it rejects new incoming call, if there is already a call.
- (CXProviderConfiguration *)providerConfiguration {
    CXProviderConfiguration *providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"AudioCallKit"];
    providerConfiguration.supportsVideo = NO;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    providerConfiguration.supportedHandleTypes = [NSSet setWithArray:@[[NSNumber numberWithInt:CXHandleTypeGeneric]]];
    providerConfiguration.ringtoneSound = @"ringtone.aiff";
    providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"CallKitLogo"]);
    return providerConfiguration;
}

- (instancetype)initWithClient:(VIClient *)client authService:(ACKAuthService *)authService {
    self = [super init];
    if (self) {
        self.client = client;
        self.authService = authService;
        self.pushCallNotifier = [[ACKPushCallNotifier alloc] initPushNotifierWithClient:client authService:authService];
        self.pushCallNotifier.delegate = self;
        self.client.callManagerDelegate = self;
        self.callProvider = [[CXProvider alloc] initWithConfiguration:self.providerConfiguration];
        [self.callProvider setDelegate:self queue:nil];
    }
    return self;
}

// The CXProvider documentation said: "The provider must be invalidated before it is deallocated."
- (void)dealloc { [self.callProvider invalidate]; }

#pragma mark - CXProviderDelegate
- (void)endCallWithUUID:(NSUUID *)uuid {
    ACKCallWrapper *call = self.managedCall;
    if (call && [call.uuid isEqual:uuid]) {
        if (!call.hasConnected && !call.isOutgoing) {
            [call.call rejectWithMode:VIRejectModeDecline headers:nil];
        } else {
            [call.call hangupWithHeaders:nil];
        }
        
        [VIAudioManager.sharedAudioManager callKitStopAudio];
        [VIAudioManager.sharedAudioManager callKitReleaseAudioSession];
    }
    // SDK will invoke VICallDelegate methods (didDisconnectWithHeaders or didFailWithError)
}


- (void)reportCallEndedWithUUID:(NSUUID *)uuid endReason:(CXCallEndedReason)endReason {
    if (self.managedCall && [self.managedCall.uuid isEqual:uuid]) {
        NSArray<CXAction *> *pendingActions = [self.callProvider pendingCallActionsOfClass:[CXAction class] withCallUUID:uuid];
        if (pendingActions.count > 0) {
            // no matter what the endReason is
            for (CXAction *action in pendingActions) {
                [action fail];
            }
        } else {
            [self.callProvider reportCallWithUUID:self.managedCall.uuid endedAtDate:[NSDate date] reason:endReason];
        }
        // Ensure the push processing is completed in cases:
        // 1. login issues
        // 2. call is rejected before the user is logged in
        // in all other cases completePushProcessing should be called in VICallDelegate methods
        [self.managedCall completePushProcessing];
        
        self.managedCall = nil;
    }
}

- (void)updateOutgoingCall:(VICall *)vicall {
    if (self.managedCall && !self.managedCall.call && [self.managedCall.uuid isEqual:vicall.callKitUUID]) {
        [self.managedCall setCall:vicall delegate:self];
        [vicall start];
        [self.callProvider reportOutgoingCallWithUUID:self.managedCall.uuid startedConnectingAtDate:nil];
    }
}

- (void)updateIncomingCall:(VICall *)vicall {
    if (self.managedCall && !self.managedCall.call && [self.managedCall.uuid isEqual:vicall.callKitUUID]) {
        [self.managedCall setCall:vicall delegate:self];
    }
}

- (void)createOutgoingCallWithUUID:(NSUUID *)callUUID {
    if (self.managedCall) { return; }
    self.managedCall = [[ACKCallWrapper alloc] initWithUUID:callUUID isOutgoing:YES];
}

- (void)createIncomingCallWithUUID:(NSUUID *)newUUID fullUsername:(NSString *)fullUsername displayName:(NSString *)displayName pushCompletion:(nullable dispatch_block_t)pushCompletion {
    if (self.managedCall) { return; }
    
    self.managedCall = [[ACKCallWrapper alloc] initWitUUID:newUUID isOutgoing:NO pushProcessingCompletion:pushCompletion];
    
    CXCallUpdate *callInfo = [[CXCallUpdate alloc] init];
    callInfo.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:fullUsername];
    callInfo.supportsHolding = YES;
    callInfo.supportsGrouping = NO;
    callInfo.supportsUngrouping = NO;
    callInfo.supportsDTMF = YES;
    callInfo.hasVideo = NO;
    callInfo.localizedCallerName = displayName;
    
    __weak ACKCallManager *weakSelf = self;
    [self.callProvider reportNewIncomingCallWithUUID:newUUID update:callInfo completion:^(NSError * _Nullable error) {
        __strong ACKCallManager *strongSelf = weakSelf;
        if (error) {
            // CallKit can reject new incoming call in the following cases (CXErrorCodeIncomingCallError):
            // - "Do Not Disturb" mode is on
            // - the caller is in the system black list
            // - ...
            [strongSelf endCallWithUUID:newUUID];
        }
    }];
}

- (BOOL)provider:(CXProvider *)provider executeTransaction:(nonnull CXTransaction *)transaction {
    if (self.authService.state == VIClientStateLoggedIn) { return NO; }
    
    if (self.authService.state == VIClientStateDisconnected) {
        __weak ACKCallManager *weakSelf = self;
        [self.authService loginUsingAccessTokenWithCompletion:^(NSString * _Nullable userDisplayName, NSError * _Nullable error) {
            __strong ACKCallManager *strongSelf = weakSelf;
            if (userDisplayName) {
                [strongSelf.callProvider commitTransactionsWithDelegate:strongSelf];
            } else if (strongSelf.managedCall.uuid) {
                [strongSelf reportCallEndedWithUUID:strongSelf.managedCall.uuid endReason:CXCallEndedReasonFailed];
            }
        }];
    }
    return YES;
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    if (self.managedCall) {
        [action fail];
        NSLog(@"CallManager performStartCallAction: tried to start the call %@ while already managed the call %@", action.callUUID, self.managedCall.uuid);
        return;
    }
    
    [self createOutgoingCallWithUUID:action.callUUID];
    NSLog(@"CallManager performStartCallAction: created new outgoing call %@", action.callUUID);
    
    VICallSettings *settings = [[VICallSettings alloc] init];
    settings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo:NO];
    
    VICall *call = [self.client call:action.handle.value settings:settings];
    if (call) {
        call.callKitUUID = action.callUUID;
        [VIAudioManager.sharedAudioManager callKitConfigureAudioSession:nil];
        [self updateOutgoingCall:call];
        NSLog(@"CallManager performStartCallAction: updated outgoing call %@", call.callKitUUID);
        [action fulfill];
    } else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    [[VIAudioManager sharedAudioManager] callKitStartAudio];
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    [[VIAudioManager sharedAudioManager] callKitStopAudio];
}

// method caused by the CXProvider.invalidate()
- (void)providerDidReset:(CXProvider *)provider {
    if (self.managedCall.uuid) { [self endCallWithUUID: self.managedCall.uuid]; }
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    [[VIAudioManager sharedAudioManager] callKitConfigureAudioSession:nil];
    
    if (!self.managedCall.call) { return; }
    
    VICallSettings *settings = [[VICallSettings alloc] init];
    settings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo:NO];
    [self.managedCall.call answerWithSettings:settings];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    if (!self.managedCall.call) { return; }
    
    [self.managedCall.call setHold:action.isOnHold completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"CallManager performSetHeldCallAction - %@", error.localizedDescription);
            [action fail];
        } else {
            [action fulfill];
        }}];
}

// the method is called, if the user rejects an incoming call or ends an outgoing call
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    [self endCallWithUUID:action.callUUID];
    [action fulfillWithDateEnded:[NSDate date]];
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    [self.managedCall.call sendDTMF:action.digits];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    [self.managedCall.call setSendAudio:!action.isMuted];
    [action fulfill];
}

#pragma mark - VICallDelegate
- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    [self reportCallEndedWithUUID:call.callKitUUID endReason:CXCallEndedReasonFailed];
    
    if (!self.managedCall) { return; }
    [self.managedCall completePushProcessing];
}


- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    CXCallEndedReason endReason = answeredElsewhere.boolValue ? CXCallEndedReasonAnsweredElsewhere : CXCallEndedReasonRemoteEnded;
    [self reportCallEndedWithUUID:call.callKitUUID endReason:endReason];
    
    if (!self.managedCall) { return; }
    [self.managedCall completePushProcessing];
}

- (void)call:(VICall *)call didConnectWithHeaders:(NSDictionary *)headers {
    if (self.managedCall) {
        if (self.managedCall.isOutgoing) {
            // notify CallKit that the outgoing call is connected
            [self.callProvider reportOutgoingCallWithUUID:self.managedCall.uuid connectedAtDate:nil];
            
            // apply the configuration to the CallKit call screen
            // for incoming calls this configuration is set when the incoming call is reported to CallKit
            CXCallUpdate *callInfo = [[CXCallUpdate alloc] init];
            callInfo.hasVideo = NO;
            callInfo.supportsHolding = YES;
            callInfo.supportsGrouping = NO;
            callInfo.supportsUngrouping = NO;
            callInfo.supportsDTMF = YES;
            if (call.endpoints.firstObject.userDisplayName) {
                callInfo.localizedCallerName = call.endpoints.firstObject.userDisplayName;
            }
            [self.callProvider reportCallWithUUID:self.managedCall.uuid updated:callInfo];
        }
        [self.managedCall setHasConnected:YES];
    }
    [self.managedCall completePushProcessing];
}

#pragma mark - VIClientCallManagerDelegate

- (void)client:(VIClient *)client pushDidExpire:(NSUUID *)callKitUUID {
    [self reportCallEndedWithUUID:callKitUUID endReason:CXCallEndedReasonFailed];
}

- (void)client:(nonnull VIClient *)client didReceiveIncomingCall:(nonnull VICall *)call withIncomingVideo:(BOOL)video headers:(nullable NSDictionary *)headers {
    if (self.managedCall) {
        if ([self.managedCall.uuid isEqual:call.callKitUUID]) {
            [self updateIncomingCall:call];
            [self.callProvider commitTransactionsWithDelegate:self];
            NSLog(@"CallManager sdk rcv: updated already managed incoming call %@", call.callKitUUID);
        } else {
            // another call has been reported, reject a new one:
            [call rejectWithMode:VIRejectModeDecline headers:nil];
            NSLog(@"CallManager sdk rcv: rejected new incoming call %@ while has already managed call %@", call.callKitUUID, self.managedCall.uuid);
        }
    } else {
        [self createIncomingCallWithUUID:call.callKitUUID fullUsername:call.endpoints.firstObject.user displayName:call.endpoints.firstObject.userDisplayName pushCompletion:nil];
        [self updateIncomingCall:call];
        NSLog(@"CallManager sdk rcv: created and updated new incoming call %@", call.callKitUUID);
    }
}

#pragma mark - PushCallNotifierDelegate

- (void)didReceiveIncomingCall:(NSUUID *)uuid from:(NSString *)fullUsername with:(NSString *)displayName with:(dispatch_block_t)completion {
    if (self.managedCall) {
        // another call has been reported, skipped a new one:
        NSLog(@"CallManager push rcv: skipped new incoming call %@ while has already managed call %@", uuid, self.managedCall.uuid);
        return;
    }
    
    [self createIncomingCallWithUUID:uuid fullUsername:fullUsername displayName:displayName pushCompletion:completion];
    NSLog(@"CallManager push rcv: created new incoming call %@", uuid);
    
    __weak ACKCallManager *weakSelf = self;
    [self.authService loginUsingAccessTokenWithCompletion:^(NSString * _Nullable userDisplayName, NSError * _Nullable error) {
        if (error) {
            __strong ACKCallManager *strongSelf = weakSelf;
            [strongSelf reportCallEndedWithUUID:uuid endReason:CXCallEndedReasonFailed];
        }
        // in case of success we will receive VICall instance via VICallManagerDelegate
    }];
    
}

@end


