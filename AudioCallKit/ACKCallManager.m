/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKCallManager.h"
#import "VoxErrors.h"
#import "ACKPushCallNotifier.h"

@implementation ACKCallWrapper

+ (instancetype)createCall:(VICall *)call uuid:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing hasConnected:(BOOL)hasConnected {
    ACKCallWrapper *ackCall = [[ACKCallWrapper alloc] init];
    ackCall.call = call;
    ackCall.uuid = uuid;
    ackCall.isOutgoing = isOutgoing;
    ackCall.hasConnected = hasConnected;
    return ackCall;
}

@end

@interface ACKCallManager ()

@property (strong, nonatomic) VIClient *client;
@property (strong, nonatomic) ACKAuthService *authService;
@property (strong, nonatomic) ACKPushCallNotifier *pushCallNotifier;
@property (strong, nonatomic, nonnull) CXProvider *callProvider;

@end


@implementation ACKCallManager

// Voximplant SDK supports multiple calls at the same time, however
// this demo app demonstrates only one managed call at the moment,
// so it rejects new incoming call, if there is already a call.
- (void)setManagedCall:(ACKCallWrapper *)managedCall {
    [managedCall.call addDelegate:self];
    _managedCall = managedCall;
}

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
        self.client.callManagerDelegate = self;
        self.callProvider = [[CXProvider alloc] initWithConfiguration:self.providerConfiguration];
        [self.callProvider setDelegate:self queue:nil];
    }
    return self;
}

- (void)dealloc {
    // The CXProvider documentation said: "The provider must be invalidated before it is deallocated."
    [self.callProvider invalidate];
}

- (void)startOutgoingCallWithContact:(NSString *)contact
                          completion:(void (^)(VICall *_Nullable call, NSError *_Nullable error))completion {
    
    VoxUser *lastLoggedInUser = self.authService.lastLoggedInUser;
    
    if (!lastLoggedInUser) { return; }
    __weak ACKCallManager *weakSelf = self;
    [self.authService loginUsingTokenWithUser:lastLoggedInUser.username
                                   completion:^(NSString *_Nullable userDisplayName, NSError *_Nullable error) {
                                       if (error) {
                                           completion(nil, error);
                                           return;
                                       }
                                       __strong ACKCallManager *strongSelf = weakSelf;
                                       if (!strongSelf.client || strongSelf.managedCall) {
                                           completion(nil, [NSError errorAlreadyHasCall]);
                                           return;
                                       }
                                       VICallSettings *settings = [[VICallSettings alloc] init];
                                       settings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo: NO];
                                       // could be nil only if client is not logged in:
                                       VICall *call = [strongSelf.client call:contact settings:settings];
                                       if (!call) {
                                           completion(nil, [NSError errorCouldntCreateCall]);
                                           return;
                                       }
                                       [call start];
                                       completion(call, nil);
                                   }];
}

#pragma mark - CXProviderDelegate
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action { // for outgoing call only
    [provider reportOutgoingCallWithUUID:action.callUUID startedConnectingAtDate:nil];
    __weak ACKCallManager *weakSelf = self;
    [self startOutgoingCallWithContact:action.handle.value
                            completion:^(VICall *_Nullable call, NSError *_Nullable error) {
        if (call) {
            __strong ACKCallManager *strongSelf = weakSelf;
            [strongSelf.managedCall.call removeDelegate:strongSelf];
            [strongSelf setManagedCall:[ACKCallWrapper createCall:call uuid:action.callUUID isOutgoing:YES hasConnected: NO]];
            [action fulfill];
        } else if (error) {
            NSLog(@"%@", error.localizedDescription);
            [action fail];
        }
    }];
    [[VIAudioManager sharedAudioManager] callKitConfigureAudioSession:nil];
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    [[VIAudioManager sharedAudioManager] callKitStartAudio];
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    [[VIAudioManager sharedAudioManager] callKitStopAudio];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    // In this sample we don't need to check the client state in this method - here we are sure we are already logged in to the Voximplant Cloud.
    [[VIAudioManager sharedAudioManager] callKitConfigureAudioSession:nil];
    VICallSettings *settings = [[VICallSettings alloc] init];
    settings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo:NO];
    [self.managedCall.call answerWithSettings:settings];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    [self.managedCall.call setHold:action.isOnHold completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            [action fail];
        } else
            [action fulfill];
    }];
}

// the method is called, if the user rejects an incoming call or ends an outgoing call
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    ACKCallWrapper *call = self.managedCall;
    if (call) {
        if (!call.hasConnected && !call.isOutgoing) {
            [call.call rejectWithMode:VIRejectModeDecline headers:nil];
        } else {
            [call.call hangupWithHeaders:nil];
        }
    }
    // If the call has been reported to CallKit and the user rejects or ends the call, callKitReleaseAudioSession method should be invoked.
    [[VIAudioManager sharedAudioManager] callKitReleaseAudioSession];
    [action fulfillWithDateEnded:[NSDate date]];
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    [self.managedCall.call sendDTMF:action.digits];  // sending dtmf to sdk
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    [self.managedCall.call setSendAudio:!action.isMuted];
    [action fulfill];
}

- (void)providerDidReset:(nonnull CXProvider *)provider {
}

#pragma mark - VICallDelegate
- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    ACKCallWrapper *managedCall = self.managedCall;
    if (managedCall && [managedCall.call.callId isEqualToString:call.callId]) {
        [self.callProvider reportCallWithUUID:managedCall.uuid endedAtDate:nil reason:CXCallEndedReasonFailed];
        self.managedCall = nil;
    }
    if (pushNotificationCompletion) {
        pushNotificationCompletion();
    }
    pushNotificationCompletion = nil;
}


- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    ACKCallWrapper *managedCall = self.managedCall;
     if (managedCall && [managedCall.call.callId isEqualToString:call.callId]) {
         CXCallEndedReason endReason = answeredElsewhere.boolValue ? CXCallEndedReasonAnsweredElsewhere : CXCallEndedReasonRemoteEnded;
         [self.callProvider reportCallWithUUID:managedCall.uuid endedAtDate:[NSDate date] reason:endReason];
         [self.managedCall.call removeDelegate:self];
         [self setManagedCall:nil];
     }
    if (pushNotificationCompletion) {
        pushNotificationCompletion();
    }
    pushNotificationCompletion = nil;
}

- (void)call:(VICall *)call didConnectWithHeaders:(NSDictionary *)headers {
    ACKCallWrapper *managedCall = self.managedCall;
    if (managedCall) {
        if (managedCall.isOutgoing) {
            // notify CallKit that the outgoing call is connected
            [self.callProvider reportOutgoingCallWithUUID:managedCall.uuid connectedAtDate:nil];
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
    if (pushNotificationCompletion) {
        pushNotificationCompletion();
    }
    pushNotificationCompletion = nil;
}


#pragma mark - VIClientCallManagerDelegate
- (void)client:(nonnull VIClient *)client didReceiveIncomingCall:(nonnull VICall *)call withIncomingVideo:(BOOL)video headers:(nullable NSDictionary *)headers {
    if (self.managedCall) {
        [call rejectWithMode:VIRejectModeBusy headers:nil];
    } else {
        CXCallUpdate *callInfo = [[CXCallUpdate alloc] init];
        callInfo.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:call.endpoints.firstObject.user];
        callInfo.hasVideo = NO;
        callInfo.supportsHolding = YES;
        callInfo.supportsGrouping = NO;
        callInfo.supportsUngrouping = NO;
        callInfo.supportsDTMF = YES;
        if (call.endpoints.firstObject.userDisplayName) {
            callInfo.localizedCallerName = call.endpoints.firstObject.userDisplayName;
        }
        
        NSUUID *newUUID = [[NSUUID alloc] init];
        
        __weak ACKCallManager *weakSelf = self;
        [self.callProvider reportNewIncomingCallWithUUID:newUUID update:callInfo
                                              completion:^(NSError * _Nullable error) {
                                                  __strong ACKCallManager *strongSelf = weakSelf;
                                                  if (error) {
                                                      NSLog(@"%@", error.localizedDescription);
                                                      // CallKit can reject new incoming call in the following cases:
                                                      // - "Do Not Disturb" mode is on
                                                      // - the caller is in the system black list
                                                  } else if (strongSelf) {
                                                      strongSelf.managedCall = [ACKCallWrapper createCall:call uuid:newUUID isOutgoing:NO hasConnected: NO];
                                                  }
                                              }];
    }
}




@end


