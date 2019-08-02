/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACCallManager.h"
#import "VoxErrors.h"


@interface ACCallManager ()

@property (nonatomic, strong) VIClient *client;
@property (nonatomic, strong) ACAuthService *authService;

@end


@implementation ACCallManager

- (instancetype)initWithClient:(VIClient *)client authService:(ACAuthService *)authService {
    self = [super init];
    if (self) {
        self.client = client;
        self.authService = authService;
        self.client.callManagerDelegate = self;
    }
    return self;
}

- (void)startOutgoingCallWithContact:(NSString *)contact completion:(void (^)(NSError *_Nullable error))completion {
    
    ACUser *lastLoggedInUser = self.authService.lastLoggedInUser;
    
    if (!lastLoggedInUser) { return; }
    __weak ACCallManager *weakSelf = self;
    [self.authService loginUsingTokenWithUser:lastLoggedInUser.username
                                   completion:^(NSString *_Nullable userDisplayName, NSError *_Nullable error) {
                                       if (error) {
                                           completion(error);
                                           return;
                                       }
                                       __strong ACCallManager *strongSelf = weakSelf;
                                       if (!strongSelf.client || strongSelf.managedCall) {
                                           completion([NSError errorAlreadyHasCall]);
                                           return;
                                       }
                                       VICallSettings *settings = [[VICallSettings alloc] init];
                                       settings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo: NO];
                                       // could be nil only if client is not logged in:
                                       VICall *call = [strongSelf.client call:contact settings:settings];
                                       if (!call) {
                                           completion([NSError errorCouldntCreateCall]);
                                           return;
                                       }
                                       [call addDelegate:strongSelf];
                                       strongSelf.managedCall = call;
                                       [call start];
                                       completion(nil);
                                   }];
}

- (void)makeIncomingCallActive {
    VICallSettings *settings = [[VICallSettings alloc]init];
    settings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo:NO];
    if (self.managedCall) {
        [self.managedCall answerWithSettings:settings];
    }
}

#pragma mark - VIClientCallManagerDelegate
- (void)client:(nonnull VIClient *)client didReceiveIncomingCall:(nonnull VICall *)call withIncomingVideo:(BOOL)video headers:(nullable NSDictionary *)headers {
    if (self.managedCall) {
        [call rejectWithMode:VIRejectModeBusy headers:nil];
    } else {
        self.managedCall = call;
        [call addDelegate:self];
        [self.delegate notifyIncomingCall:call];
    }
}


#pragma mark - VICallDelegate
- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    if (call.callId && self.managedCall.callId && [call.callId isEqualToString:self.managedCall.callId]) {
        [call removeDelegate:self];
        self.managedCall = nil;
    }
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    if (call.callId && self.managedCall.callId && [call.callId isEqualToString:self.managedCall.callId]) {
        [call removeDelegate:self];
        self.managedCall = nil;
    }
}

@end


