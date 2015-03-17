//
//  MCPeer.m
//  Multihop
//
//  Created by quarta on 16/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHPeer.h"


@interface MHPeer () <MCSessionDelegate>

// Public Properties
@property (nonatomic, readwrite, strong) NSString *displayName;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *mcPeerID;
@property (nonatomic, strong) NSString *mhPeerID;
@property (nonatomic) int nbHeartbeatFails;

@property (nonatomic, strong) NSString *HeartbeatMsg;
@property (nonatomic, strong) NSString *AckMsg;

@property (copy) void (^sendHeartbeat)(void);

@end


@implementation MHPeer


#pragma mark - Life Cycle

- (instancetype)initWithDisplayName:(NSString *)displayName
     withOwnMCPeerID:(MCPeerID *)ownMCPeerID
        withMCPeerID:(MCPeerID *)mcPeerID
        withMHPeerID:(NSString *)mhPeerID
{
    self = [super init];
    if (self)
    {
        self.nbHeartbeatFails = 0;
        self.HeartbeatMsg = @"[{_-heartbeat-_}]";
        self.AckMsg = @"[{_-ack-_}]";
        
        self.displayName = displayName;
        self.mcPeerID = mcPeerID;
        self.mhPeerID = mhPeerID;
        
        self.session = [[MCSession alloc] initWithPeer:ownMCPeerID
                                      securityIdentity:nil
                                  encryptionPreference:MCEncryptionRequired];
        self.session.delegate = self;
        
        
        MHPeer * __weak weakSelf = self;
        
        self.sendHeartbeat = ^{
            weakSelf.nbHeartbeatFails++;
            
            // The heartbeat fails for 3 times, then disconnect
            if (weakSelf.nbHeartbeatFails > 3)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.delegate mhPeer:weakSelf hasDisconnected:@"Disconnected"];
                });
            }
            else
            {
                NSError *error;
                
                [weakSelf.session sendData:[weakSelf.HeartbeatMsg dataUsingEncoding:NSUTF8StringEncoding] toPeers:weakSelf.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
                
                
                // Dispatch after 1-3 seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(2) + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.sendHeartbeat);
            }
        };
        
        
        // Dispatch after 1-3 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(2) + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), self.sendHeartbeat);
    }
    return self;
}


- (void)dealloc
{
    // Will clean up the session properly
    [self.session disconnect];
    self.session = nil;
    self.mcPeerID = nil;
}


#pragma mark - Session Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(state == MCSessionStateNotConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate mhPeer:self hasDisconnected:@"Disconnected"];
        });
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // TODO: find a faster way to check if it is the heartbeat msg
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([dataStr isEqualToString:self.HeartbeatMsg])
    {
        self.nbHeartbeatFails = 0;
        NSError *error;
        
        [self.session sendData:[self.AckMsg dataUsingEncoding:NSUTF8StringEncoding] toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    }
    else if ([dataStr isEqualToString:self.AckMsg])
    {
        self.nbHeartbeatFails = 0;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(mhPeer:didReceiveData:)])
            {
                [self.delegate mhPeer:self didReceiveData:data];
            }
        });
    }
}


- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
   // Unsupported: Nothing to do
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    // Unsupported: Nothing to do
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
   // Unsupported: Nothing to do
}

// Required because of an apple bug
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}



# pragma mark - Static methods

+ (MHPeer *)getOwnMHPeerWithDisplayName:(NSString *)displayName
{
    NSString *mhPeerID = [[NSUserDefaults standardUserDefaults] valueForKey:@"MultihopID"];
    
    if(mhPeerID == nil)
    {
        mhPeerID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:mhPeerID forKey:@"MultihopID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    MCPeerID *mcPeerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    return [[MHPeer alloc] initWithDisplayName:displayName withOwnMCPeerID:mcPeerID withMCPeerID:mcPeerID withMHPeerID:mhPeerID];
}


@end
