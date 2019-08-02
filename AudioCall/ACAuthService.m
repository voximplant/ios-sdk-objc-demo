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
    return keys.refreshToken.expireDate;
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
                                     success:^(NSString * _Nonnull userDisplayName, NSDictionary * _Nonnull tokens) {
                                         NSNumber *refreshExpire = tokens[@"refreshExpire"];
                                         NSString *refreshKey = tokens[@"refreshToken"];
                                         NSNumber *accessExpire = tokens[@"accessExpire"];
                                         NSString *accessKey = tokens[@"accessToken"];
                                         
                                         if (refreshExpire && refreshKey && accessExpire && accessKey) {
                                             __strong ACAuthService *strongSelf = weakSelf;
                                             
                                             ACToken *accessToken = [ACToken tokenWithKey:accessKey
                                                                             expireDate:[NSDate dateWithTimeIntervalSinceNow:[accessExpire doubleValue]]];
                                             
                                             ACToken *refreshToken = [ACToken tokenWithKey:refreshKey
                                                                              expireDate:[NSDate dateWithTimeIntervalSinceNow:[refreshExpire doubleValue]]];
                                             ACKeys *keys = [ACKeys keyholderWithAccessToken:accessToken refreshKey:refreshToken];
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
                                           token:accessToken.key
                                         success:^(NSString * _Nonnull userDisplayName, NSDictionary * _Nonnull tokens) {
                                             NSNumber *refreshExpire = tokens[@"refreshExpire"];
                                             NSString *refreshKey = [self extracted:tokens];
                                             NSNumber *accessExpire = tokens[@"accessExpire"];
                                             NSString *accessKey = tokens[@"accessToken"];
                                             
                                             if (refreshExpire && refreshKey && accessExpire && accessKey) {
                                                 ACToken *accessToken = [ACToken tokenWithKey:accessKey
                                                                                   expireDate:[NSDate dateWithTimeIntervalSinceNow:[accessExpire doubleValue]]];
                                                 ACToken *refreshToken = [ACToken tokenWithKey:refreshKey
                                                                                    expireDate:[NSDate dateWithTimeIntervalSinceNow:[refreshExpire doubleValue]]];
                                                 ACKeys *keys = [ACKeys keyholderWithAccessToken:accessToken refreshKey:refreshToken];
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
    
    ACToken *accessKey = [self.tokenManager getKeys].accessToken;
    ACToken *refreshKey = [self.tokenManager getKeys].refreshToken;
    
    if (accessKey) {
        completion(accessKey, nil);
        return;
    }
    
    if (refreshKey) {
        __weak ACAuthService *weakSelf = self;
        [self.client refreshTokenWithUser:user
                                    token:refreshKey.key
                                   result:^(NSDictionary * _Nullable tokens, NSError * _Nullable error) {
                                       NSNumber *refreshExpire = tokens[@"refreshExpire"];
                                       NSString *refreshKey = tokens[@"refreshToken"];
                                       NSNumber *accessExpire = tokens[@"accessExpire"];
                                       NSString *accessKey = tokens[@"accessToken"];
                                       
                                       if (error) {
                                           completion(nil, error);
                                           return;
                                       }
                                       
                                       if (refreshExpire && refreshKey && accessExpire && accessKey) {
                                           __strong ACAuthService *strongSelf = weakSelf;
                                           ACToken *accessToken = [ACToken tokenWithKey:accessKey
                                                                             expireDate:[NSDate dateWithTimeIntervalSinceNow:[accessExpire doubleValue]]];
                                           ACToken *refreshToken = [ACToken tokenWithKey:refreshKey
                                                                              expireDate:[NSDate dateWithTimeIntervalSinceNow:[refreshExpire doubleValue]]];
                                           ACKeys *keys = [ACKeys keyholderWithAccessToken:accessToken refreshKey:refreshToken];
                                           
                                           [strongSelf.tokenManager setKeys:keys];
                                           completion(accessToken, nil);
                                       }
                                   }];
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
