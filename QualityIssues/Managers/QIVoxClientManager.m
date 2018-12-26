/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "QIVoxClientManager.h"

@interface QIVoxClientManager () <VIClientSessionDelegate, VIClientCallManagerDelegate>

@property (strong, nonatomic) VIClient *client;
@property (strong, nonatomic) NSHashTable *listeners;

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;

@property (strong, nonatomic, readwrite) VICall *currentCall;

@end

@implementation QIVoxClientManager

- (instancetype)initWithClient:(VIClient *)client {
    self = [super init];

    if (self) {
        _client = client;
        _client.sessionDelegate = self;
        _client.callManagerDelegate = self;

        _listeners = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }

    return self;
}

- (void)addListener:(id<QIVoxClientManagerListener>)listener {
    [_listeners addObject:listener];
}

- (void)removeListener:(id<QIVoxClientManagerListener>)listener {
    [_listeners removeObject:listener];
}

- (VILoginSuccess)loginSuccess {
    __weak QIVoxClientManager *weakSelf = self;
    return ^(NSString * _Nonnull displayName, NSDictionary * _Nonnull authParams) {
        __strong QIVoxClientManager *strongSelf = weakSelf;
        for (id<QIVoxClientManagerListener> listener in strongSelf.listeners) {
            if ([listener respondsToSelector:@selector(loginDidSucceedWithName:)]) {
                [listener loginDidSucceedWithName:displayName];
            }
        }
    };
}

- (VILoginFailure)loginFailure {
    __weak QIVoxClientManager *weakSelf = self;
    return ^(NSError * _Nonnull error) {
        __strong QIVoxClientManager *strongSelf = weakSelf;
        for (id<QIVoxClientManagerListener> listener in strongSelf.listeners) {
            if ([listener respondsToSelector:@selector(loginDidFailWithError:)]) {
                [listener loginDidFailWithError:error];
            }
        }
    };
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password {
    _username = username;
    _password = password;

    if (_client) {
        if (_client.clientState == VIClientStateDisconnected) {
            [_client connect];
        } else {
            [_client loginWithUser:_username
                          password:_password
                           success:self.loginSuccess
                           failure:self.loginFailure];
        }
    }
}

- (void)logout {
    if (_client && _client.clientState != VIClientStateDisconnected) {
        [_client disconnect];
    }
}

- (void)client:(nonnull VIClient *)client sessionDidFailConnectWithError:(nonnull NSError *)error {
    for (id<QIVoxClientManagerListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(connectionDidClose:)]) {
            [listener connectionDidClose:error];
        }
    }
}

- (void)clientSessionDidConnect:(nonnull VIClient *)client {
    if ([_client isEqual:client]) {
        [_client loginWithUser:_username
                      password:_password
                       success:self.loginSuccess
                       failure:self.loginFailure];
    }
}

- (void)clientSessionDidDisconnect:(nonnull VIClient *)client {
    for (id<QIVoxClientManagerListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(connectionDidClose:)]) {
            [listener connectionDidClose:nil];
        }
    }
}

- (void)client:(nonnull VIClient *)client didReceiveIncomingCall:(nonnull VICall *)call withIncomingVideo:(BOOL)video headers:(nullable NSDictionary *)headers {
    if (_currentCall) {
        [call rejectWithMode:VIRejectModeBusy headers:nil];
        return;
    }

    _currentCall = call;

    VIVideoFlags *videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:video sendVideo:video];
    for (id<QIVoxClientManagerListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(incomingCallReceived:withVideoFlags:)]) {
            [listener incomingCallReceived:_currentCall withVideoFlags:videoFlags];
        }
    }
}

- (VICall *)createCall:(NSString *)user withVideoFlags:(VIVideoFlags *)videoFlags {
    if (_currentCall) {
        return nil;
    }

    VICallSettings *callSettings = [VICallSettings new];
    callSettings.videoFlags = videoFlags;

    _currentCall = [_client call:user settings:callSettings];

    return _currentCall;
}

- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    if (call == _currentCall) {
        _currentCall = nil;
    }
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    if (call == _currentCall) {
        _currentCall = nil;
    }
}

@end
