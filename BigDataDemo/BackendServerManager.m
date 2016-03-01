/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    BackendServerManager.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/25/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "BackendServerManager.h"
#import "ConfigurationDataManager.h"
#import "Util.h"
#import "SRWebSocket.h"

NSString *const kBackendServerDidConnectNotification        = @"backend_server_did_connect_notification";
NSString *const kBackendServerDidFailToConnectNotification  = @"backend_server_did_fail_to_connect_notification";
NSString *const kBackendServerDidDisconnectNotification     = @"backend_server_did_disconnect_notification";
NSString *const kBackendServerDidFailToSendDataNotification = @"backend_server_did_fail_to_send_data_notification";
NSString *const kBackendServerDidReceiveDataNotification    = @"backend_server_did_receive_data_notification";
NSString *const kBackendServerNotificationDataKey           = @"backend_server_notification_data_key";
NSString *const kBackendServerNotificationErrorKey          = @"backend_server_notification_error_key";


@interface BackendServerManager () <SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic) BOOL isConnected;
@end

@implementation BackendServerManager
{

}

+ (id)sharedManager
{
    static BackendServerManager *_sharedBackendServerManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedBackendServerManager = [[BackendServerManager alloc] init];
    });

    return _sharedBackendServerManager;
}

+ (void)start
{
    [[BackendServerManager sharedManager] registerObservers];
    [[BackendServerManager sharedManager] reconnectToServer];
}

- (void)reconnectToServer
{
    if (self.isConnected)
    {
        [self.webSocket close];
    }
    if ([ConfigurationDataManager hasValidConfigurationData])
    {
        [self setWebSocket:[[SRWebSocket alloc] initWithURL:[ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws"]]];
        [self.webSocket setDelegate:self];
        [self.webSocket open];
    }
}

+ (void)sendData:(NSString *)data
{
    DLog(@"Socket send: @%", data);
    [[[BackendServerManager sharedManager] webSocket] send:data];
}

+ (BOOL)isConnected
{
    return [[BackendServerManager sharedManager] isConnected];
}

- (void)registerObservers
{
    [ConfigurationDataManager addObserver:self
                               forKeyPath:kConfigurationDataManagerServerUrlKeyPath
                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                  context:NULL];

    [ConfigurationDataManager addObserver:self
                               forKeyPath:kConfigurationDataManagerServerPortKeyPath
                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                  context:NULL];
}

- (void)unregisterObservers
{
    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerServerUrlKeyPath];

    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerServerPortKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([keyPath isEqualToString:kConfigurationDataManagerServerUrlKeyPath] || [keyPath isEqualToString:kConfigurationDataManagerServerPortKeyPath])
        [self reconnectToServer];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    DLog(@"Socket open");

    self.isConnected = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidConnectNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    DLog(@"Socket error: %@", reason);

    self.isConnected = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidFailToConnectNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationErrorKey : reason}];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    DLog(@"Socket receive: %@", message);

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidReceiveDataNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationDataKey : message}];

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    DLog(@"Socket error: %@", error.localizedDescription);

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidFailToSendDataNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationErrorKey : error}];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    DLog(@"Socket pong");
}

@end