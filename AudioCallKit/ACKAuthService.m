/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKAuthService.h"
#import "VoxKeys.h"
#import "VoxTokenManager.h"
#import "VoxErrors.h"


@interface NSUserDefaults (lastUser)

@property (strong, nonatomic, readonly) NSString *lastFullUsername;

@end


@implementation NSUserDefaults (lastUser)

- (NSString *)lastFullUsername {
    return [[[UIApplication userDefaultsDomain] stringByAppendingString:@"."] stringByAppendingString:@"lastFullUsername"];
}

@end

#pragma mark - Auth Service
@interface ACKAuthService () <VIClientSessionDelegate>

@property (strong, nonatomic) VIClient *client;
@property (strong, nonatomic) VICall *currentCall;
@property (copy, nonatomic) void (^connectCompletion)(NSString *_Nullable, NSError *_Nullable);
@property (copy, nonatomic) void (^disconnectCompletion)(void);
@property (strong, nonatomic) VoxTokenManager *tokenManager;

- (void)connect: (void (^)(NSString *, NSError *))completion;

@end


@implementation ACKAuthService

- (void)setPushToken:(NSData *)pushToken {
    if (!pushToken) {
        [self.client unregisterVoIPPushNotificationsToken:self.pushToken completion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"unregister VoIP token failed with error %@", error.localizedDescription);
            }
        }];
    }
    _pushToken = pushToken;
}

- (NSString *)loggedInUser {
    return [NSUserDefaults.standardUserDefaults stringForKey:NSUserDefaults.standardUserDefaults.lastFullUsername];
}

- (void)setLoggedInUser:(NSString *)newValue {
    [NSUserDefaults.standardUserDefaults setValue:newValue forKey:NSUserDefaults.standardUserDefaults.lastFullUsername];
}

- (VIClientState)state {
    return self.client.clientState;
}

#pragma mark - Init
- (instancetype)initWithClient:(VIClient *)client {
    self = [super init];
    if (self) {
        self.client = client;
        self.client.sessionDelegate = self;
        self.tokenManager = [[VoxTokenManager alloc] init];
    }
    return self;
}

#pragma mark - Login methods
- (NSDate *)possibleToLogin {
    VoxKeys *keys = [self.tokenManager getKeys];
    return keys.refresh.expireDate;
}

- (void)loginWithUser:(NSString *)user
             password:(NSString *)password
               result:(VoxResult)completion {
    
    __weak ACKAuthService *weakSelf = self;
    [self disconnect:^(void) {
        
        __strong ACKAuthService *strongSelf = weakSelf;
        [strongSelf connect:^(NSString *userDisplayName,NSError *error) {
            
            if (error) {
                completion(nil, error);
                return;
            }
            
            __strong ACKAuthService *strongSelf = weakSelf;
            [strongSelf.client loginWithUser:user
                                    password:password
                                     success:^(NSString * _Nonnull userDisplayName, VIAuthParams * _Nonnull authParams) {
                                         NSTimeInterval refreshExpire = authParams.refreshExpire;
                                         NSString *refreshToken = authParams.refreshToken;
                                         NSTimeInterval accessExpire = authParams.accessExpire;
                                         NSString *accessToken = authParams.accessToken;

                                         __strong ACKAuthService *strongSelf = weakSelf;
                                         
                                         VoxToken *validAccessToken = [VoxToken createToken:accessToken
                                                                               expireDate:[NSDate dateWithTimeIntervalSinceNow:accessExpire]];
                                         
                                         VoxToken *validRefreshToken = [VoxToken createToken:refreshToken
                                                                                expireDate:[NSDate dateWithTimeIntervalSinceNow:refreshExpire]];
                                         VoxKeys *keys = [VoxKeys keyholderWithAccess:validAccessToken refresh:validRefreshToken];
                                         [strongSelf.tokenManager setKeys:keys];
                                         strongSelf.loggedInUser = user;
                                         strongSelf.loggedInUserDisplayName = userDisplayName;
                                         [strongSelf.client registerVoIPPushNotificationsToken:strongSelf.pushToken
                                                                                    completion:^(NSError * _Nullable error) {
                                             if (error) {
                                                 NSLog(@"register VoIP token failed with error %@", error.localizedDescription);
                                             }
                                         }];
                                         completion(userDisplayName, nil);
                                     }
                                     failure:^(NSError * _Nonnull error) {
                                         completion(nil, error);
                                     }];
        }];
    }];
}

- (NSString *)extracted:(NSDictionary * _Nonnull)tokens {
    NSString *refreshToken = tokens[@"refreshToken"];
    return refreshToken;
}

- (void)loginUsingAccessTokenWithCompletion:(VoxResult)completion {
    
    NSString *user = self.loggedInUser;
    if (!user) {
        NSError *error = [NSError errorRequiredPassword];
        completion(nil, error);
        return;
    }
    
    if (self.state == VIClientStateLoggedIn && self.loggedInUserDisplayName && !self.tokenManager.getKeys.refresh.isExpired) {
        completion(self.loggedInUserDisplayName, nil);
        return;
    }
    
    __weak ACKAuthService *weakSelf = self;
        [self connect:^(NSString *userDisplayName, NSError *error) {
            
            if (error) {
                completion(nil, error);
                return;
            }
            __strong ACKAuthService *strongSelf = weakSelf;
            [strongSelf updateAccessTokenIfNeeded:user
                                       completion:^(VoxToken * _Nullable accessToken, NSError * _Nullable error) {
                if (error) {
                    completion(nil, error);
                    return;
                }
                __strong ACKAuthService *strongSelf = weakSelf;
                [strongSelf.client loginWithUser:user
                                           token:accessToken.token
                                         success:^(NSString * _Nonnull userDisplayName, VIAuthParams * _Nonnull authParams) {
                                             NSTimeInterval refreshExpire = authParams.refreshExpire;
                                             NSString *refreshToken = authParams.refreshToken;
                                             NSTimeInterval accessExpire = authParams.accessExpire;
                                             NSString *accessToken = authParams.accessToken;

                                             VoxToken *validAccessToken = [VoxToken createToken:accessToken
                                                                                   expireDate:[NSDate dateWithTimeIntervalSinceNow:accessExpire]];
                                             VoxToken *validRefreshToken = [VoxToken createToken:refreshToken
                                                                                    expireDate:[NSDate dateWithTimeIntervalSinceNow:refreshExpire]];
                                             VoxKeys *keys = [VoxKeys keyholderWithAccess:validAccessToken refresh:validRefreshToken];
                                             [strongSelf.tokenManager setKeys:keys];
                                             strongSelf.loggedInUser = user;
                                             strongSelf.loggedInUserDisplayName = userDisplayName;
                                             [strongSelf.client registerVoIPPushNotificationsToken:strongSelf.pushToken
                                                                                        completion:^(NSError * _Nullable error) {
                                                 if (error) {
                                                     NSLog(@"register VoIP token failed with error %@", error.localizedDescription);
                                                 }
                                             }];
                                             completion(userDisplayName, nil);
                                             
                                         } failure:^(NSError * _Nonnull error) {
                                             completion(nil, error);
                                         }];
            }];
        }];
}

- (void)updateAccessTokenIfNeeded:(NSString *)user
                       completion:(void(^)(VoxToken *_Nullable accessToken, NSError *_Nullable error))completion {
    
    VoxKeys *tokens = self.tokenManager.getKeys;
    
    if (tokens) {
        __weak ACKAuthService *weakSelf = self;
        if (tokens.access.isExpired) {
            [self.client refreshTokenWithUser:user
                                        token:tokens.refresh.token
                                       result:^(VIAuthParams * _Nullable authParams, NSError * _Nullable error) {
                                           if (error) {
                                               completion(nil, error);
                                               return;
                                           }
                                           
                                           if (authParams) {
                                               NSTimeInterval refreshExpire = authParams.refreshExpire;
                                               NSString *refreshToken = authParams.refreshToken;
                                               NSTimeInterval accessExpire = authParams.accessExpire;
                                               NSString *accessToken = authParams.accessToken;

                                               __strong ACKAuthService *strongSelf = weakSelf;
                                               VoxToken *validAccessToken = [VoxToken createToken:accessToken
                                                                                     expireDate:[NSDate dateWithTimeIntervalSinceNow:accessExpire]];
                                               VoxToken *validRefreshToken = [VoxToken createToken:refreshToken
                                                                                      expireDate:[NSDate dateWithTimeIntervalSinceNow:refreshExpire]];
                                               VoxKeys *keys = [VoxKeys keyholderWithAccess:validAccessToken refresh:validRefreshToken];
                                               
                                               [strongSelf.tokenManager setKeys:keys];
                                               completion(validAccessToken, nil);
                                               return;
                                           }
                                       }];
        } else {
            completion(tokens.access, nil);
        }
    } else {
        completion(nil, [NSError errorRequiredPassword]);
    }
}

#pragma mark - Connect methods
- (void)connect:(void (^)(NSString *userDisplayName, NSError *error))completion {
    if (self.state == VIClientStateDisconnected
        || self.state == VIClientStateConnecting) {
        self.connectCompletion = completion;
        [self.client connect];
    } else {
        completion(nil, nil);
    }
}

- (void)disconnect:(dispatch_block_t)completion {
    if (self.state == VIClientStateDisconnected) {
        completion();
    } else {
        self.disconnectCompletion = completion;
        [self.client disconnect];
    }
}

- (void)logout:(dispatch_block_t)completion {
    __weak ACKAuthService *weakSelf = self;
    [self.client unregisterVoIPPushNotificationsToken:self.pushToken completion:^(NSError * _Nullable error) {
        __strong ACKAuthService *strongSelf = weakSelf;
        if (error) {
            NSLog(@"unregister VoIP token failed with error %@", error.localizedDescription);
        }
        [strongSelf.tokenManager setKeys:nil];
        [strongSelf disconnect:completion];
    }];
}

#pragma mark - VIClient delegate methods
- (void)clientSessionDidConnect:(nonnull VIClient *)client {
    if (self.connectCompletion) {
        self.connectCompletion(nil,nil);
    }
    self.connectCompletion = nil;
}

- (void)client:(nonnull VIClient *)client sessionDidFailConnectWithError:(nonnull NSError *)error {
    if (self.connectCompletion) {
        self.connectCompletion(nil, error);
    }
    self.connectCompletion = nil;
}

- (void)clientSessionDidDisconnect:(nonnull VIClient *)client {
    if (self.disconnectCompletion) {
        self.disconnectCompletion();
    }
    self.disconnectCompletion = nil;
}

@end
