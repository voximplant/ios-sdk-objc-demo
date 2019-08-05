/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACAuthService.h"
#import "ACKeys.h"
#import "ACTokenManager.h"
#import "VoxErrors.h"


@interface NSUserDefaults (lastUser)

@property (strong, nonatomic, readonly) NSString *lastUserIDKey;
@property (strong, nonatomic, readonly) NSString *lastUserDisplayNameKey;

@end


@implementation NSUserDefaults (lastUser)

- (NSString *)lastUserIDKey {
    return [[[UIApplication userDefaultsDomain] stringByAppendingString:@"."] stringByAppendingString:@"latestUserID"];
}
- (NSString *)lastUserDisplayNameKey {
    return [[[UIApplication userDefaultsDomain] stringByAppendingString:@"."] stringByAppendingString:@"latestUserDisplayName"];
}

@end

#pragma mark - Auth Service
@interface ACAuthService () <VIClientSessionDelegate>

@property (strong, nonatomic) VIClient *client;
@property (strong, nonatomic) VICall *currentCall;
@property (copy, nonatomic) void (^connectCompletion)(NSString *_Nullable, NSError *_Nullable);
@property (copy, nonatomic) void (^disconnectCompletion)(void);
@property (strong, nonatomic) ACTokenManager *tokenManager;

- (void)connect: (void (^)(NSString *, NSError *))completion;

@end


@implementation ACAuthService

- (ACUser *)lastLoggedInUser {
    NSString *username = [NSUserDefaults.standardUserDefaults stringForKey:NSUserDefaults.standardUserDefaults.lastUserIDKey];
    NSString *displayName = [NSUserDefaults.standardUserDefaults stringForKey:NSUserDefaults.standardUserDefaults.lastUserDisplayNameKey];
    if (username && displayName) {
        return [ACUser userWithUsername:username displayName:displayName];
    }
    return nil;
}

- (void)setLastLoggedInUser:(ACUser *)newValue {
    [NSUserDefaults.standardUserDefaults setValue:newValue.username forKey:NSUserDefaults.standardUserDefaults.lastUserIDKey];
    [NSUserDefaults.standardUserDefaults setValue:newValue.displayName forKey:NSUserDefaults.standardUserDefaults.lastUserDisplayNameKey];
}

#pragma mark - Init
- (instancetype)initWithClient:(VIClient *)client {
    self = [super init];
    if (self) {
        self.client = client;
        self.client.sessionDelegate = self;
        self.tokenManager = [[ACTokenManager alloc] init];
    }
    return self;
}

#pragma mark - Login methods
- (NSDate *)possibleToLogin {
    ACKeys *keys = [self.tokenManager getKeys];
    return keys.refresh.expireDate;
}

- (void)loginWithUser:(NSString *)user
             password:(NSString *)password
               result:(ACResult)completion {
    
    __weak ACAuthService *weakSelf = self;
    [self disconnect:^(void) {
        
        __strong ACAuthService *strongSelf = weakSelf;
        [strongSelf connect:^(NSString *userDisplayName,NSError *error) {
            
            if (error) {
                completion(nil, error);
                return;
            }
            
            __strong ACAuthService *strongSelf = weakSelf;
            [strongSelf.client loginWithUser:user
                                    password:password
                                     success:^(NSString * _Nonnull userDisplayName, NSDictionary * _Nonnull authParams) {
                                         NSNumber *refreshExpire = authParams[@"refreshExpire"];
                                         NSString *refreshToken = authParams[@"refreshToken"];
                                         NSNumber *accessExpire = authParams[@"accessExpire"];
                                         NSString *accessToken = authParams[@"accessToken"];
                                         
                                         if (refreshExpire && refreshToken && accessExpire && accessToken) {
                                             __strong ACAuthService *strongSelf = weakSelf;
                                             
                                             ACToken *validAccessToken = [ACToken createToken:accessToken
                                                                                   expireDate:[NSDate dateWithTimeIntervalSinceNow:[accessExpire doubleValue]]];
                                             
                                             ACToken *validRefreshToken = [ACToken createToken:refreshToken
                                                                                    expireDate:[NSDate dateWithTimeIntervalSinceNow:[refreshExpire doubleValue]]];
                                             ACKeys *keys = [ACKeys keyholderWithAccess:validAccessToken refresh:validRefreshToken];
                                             [strongSelf.tokenManager setKeys:keys];
                                             strongSelf.lastLoggedInUser = [ACUser userWithUsername:user displayName:userDisplayName];
                                         }
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

- (void)loginUsingTokenWithUser:(NSString *)user completion:(ACResult)completion {
    
    if (self.client.clientState == VIClientStateLoggedIn) {
        completion(self.lastLoggedInUser.displayName, nil);
        return;
    }
    
    __weak ACAuthService *weakSelf = self;
    [self disconnect:^(void) {
        
        __strong ACAuthService *strongSelf = weakSelf;
        [strongSelf connect:^(NSString *userDisplayName, NSError *error) {
            
            if (error) {
                completion(nil, error);
                return;
            }
            
            __strong ACAuthService *strongSelf = weakSelf;
            [strongSelf updateAccessTokenIfNeeded:user completion:^(ACToken * _Nullable accessToken, NSError * _Nullable error) {
                if (error) {
                    completion(nil, error);
                    return;
                }
                __strong ACAuthService *strongSelf = weakSelf;
                [strongSelf.client loginWithUser:user
                                           token:accessToken.token
                                         success:^(NSString * _Nonnull userDisplayName, NSDictionary * _Nonnull authParams) {
                                             NSNumber *refreshExpire = authParams[@"refreshExpire"];
                                             NSString *refreshToken = authParams[@"refreshToken"];
                                             NSNumber *accessExpire = authParams[@"accessExpire"];
                                             NSString *accessToken = authParams[@"accessToken"];
                                             
                                             if (refreshExpire && refreshToken && accessExpire && accessToken) {
                                                 ACToken *validAccessToken = [ACToken createToken:accessToken
                                                                                       expireDate:[NSDate dateWithTimeIntervalSinceNow:[accessExpire doubleValue]]];
                                                 ACToken *validRefreshToken = [ACToken createToken:refreshToken
                                                                                        expireDate:[NSDate dateWithTimeIntervalSinceNow:[refreshExpire doubleValue]]];
                                                 ACKeys *keys = [ACKeys keyholderWithAccess:validAccessToken refresh:validRefreshToken];
                                                 [strongSelf.tokenManager setKeys:keys];
                                                 strongSelf.lastLoggedInUser = [ACUser userWithUsername:user displayName:userDisplayName];
                                             }
                                             completion(userDisplayName, nil);
                                             
                                         } failure:^(NSError * _Nonnull error) {
                                             completion(nil, error);
                                         }];
            }];
        }];
    }];
}

- (void)updateAccessTokenIfNeeded:(NSString *)user
                       completion:(void(^)(ACToken *_Nullable accessToken, NSError *_Nullable error))completion {
    
    ACKeys *tokens = self.tokenManager.getKeys;
    
    if (tokens) {
        __weak ACAuthService *weakSelf = self;
        if (tokens.access.isExpired) {
            [self.client refreshTokenWithUser:user
                                        token:tokens.refresh.token
                                       result:^(NSDictionary * _Nullable authParams, NSError * _Nullable error) {
                                           NSNumber *refreshExpire = authParams[@"refreshExpire"];
                                           NSString *refreshToken = authParams[@"refreshToken"];
                                           NSNumber *accessExpire = authParams[@"accessExpire"];
                                           NSString *accessToken = authParams[@"accessToken"];
                                           
                                           if (error) {
                                               completion(nil, error);
                                               return;
                                           }
                                           
                                           if (refreshExpire && refreshToken && accessExpire && accessToken) {
                                               __strong ACAuthService *strongSelf = weakSelf;
                                               ACToken *validAccessToken = [ACToken createToken:accessToken
                                                                                     expireDate:[NSDate dateWithTimeIntervalSinceNow:[accessExpire doubleValue]]];
                                               ACToken *validRefreshToken = [ACToken createToken:refreshToken
                                                                                      expireDate:[NSDate dateWithTimeIntervalSinceNow:[refreshExpire doubleValue]]];
                                               ACKeys *keys = [ACKeys keyholderWithAccess:validAccessToken refresh:validRefreshToken];
                                               
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
    if (self.client.clientState == VIClientStateDisconnected
        || self.client.clientState == VIClientStateConnecting) {
        self.connectCompletion = completion;
        [self.client connect];
    } else {
        completion(nil, nil);
    }
}

- (void)disconnect:(dispatch_block_t)completion {
    if (self.client.clientState == VIClientStateDisconnected) {
        completion();
    } else {
        self.disconnectCompletion = completion;
        [self.client disconnect];
    }
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
