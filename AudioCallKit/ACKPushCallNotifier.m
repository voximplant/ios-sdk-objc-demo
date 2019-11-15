/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKPushCallNotifier.h"

@interface ACKPushCallNotifier ()

@property (strong, nonatomic)PKPushRegistry *voipRegistry;
@property (strong, nonatomic)VIClient *client;
@property (strong, nonatomic)ACKAuthService *authService;

@end


// Create the PushCallNotifier instance on application launch
// This is obligatory to receive incoming calls via VoIP push from not launched application state
@implementation ACKPushCallNotifier

#pragma mark - Init

- (instancetype)initPushNotifierWithClient:(VIClient *)client authService:(ACKAuthService *)authService {
    self = [super init]; {
        if (self) {
            self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
            self.client = client;
            self.authService = authService;
            self.voipRegistry.delegate = self;
            
            // check if pushToken is already available
            // if not, request it from PushKit (see - (void)pushRegistry:registry didUpdatePushCredentials:pushCredentials forType:type)
            NSData *token = [self.voipRegistry pushTokenForType:PKPushTypeVoIP];
            if (token) {
                [self.authService setPushToken:token];
            } else {
                self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
            }
        }
        return self;
    }
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials
             forType:(PKPushType)type {
    
    NSUInteger dataLength = [pushCredentials.token length];
    NSMutableString *tokenAsString = [NSMutableString stringWithCapacity:dataLength*2];
    const unsigned char *dataBytes = [pushCredentials.token bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [tokenAsString appendFormat:@"%02x", dataBytes[idx]];
    }
    
    NSLog(@"New push credentials: %@ for %@", tokenAsString, type);
    [self.authService setPushToken:pushCredentials.token];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    NSLog(@"%@ Push received %@", type, payload);
    
    [self handlePushNotificationWithPayload:payload.dictionaryPayload pushCompletion:completion];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    NSLog(@"%@ Push received %@", type, payload);

    [self handlePushNotificationWithPayload:payload.dictionaryPayload pushCompletion:nil];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    [self.authService setPushToken:nil];
}

#pragma mark - PushCallNotifierDelegate

- (void)handlePushNotificationWithPayload:(NSDictionary *)pushPayload pushCompletion:(nullable dispatch_block_t)pushCompletion {
    NSUUID *callUUID = [self.client handlePushNotification:pushPayload];
    NSString *displayName = [[pushPayload valueForKey:@"voximplant"] valueForKey:@"display_name"];
    NSString *username = [[pushPayload valueForKey:@"voximplant"] valueForKey:@"display_name"];
    
    [self.delegate didReceiveIncomingCall:callUUID from:username with:displayName with:pushCompletion];
}


@end

