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

@property (nonatomic, strong) MHPeerBuffer *peerBuffer;

@property (nonatomic) BOOL connected;

@property (nonatomic) BOOL heartbeatStarted;
@property (nonatomic) int nbHeartbeatFails;
@property (nonatomic) BOOL HeartbeatSender;

@property (copy) void (^processHeartbeat)(void);

@end


@implementation MHPeer


#pragma mark - Life Cycle

- (instancetype)initWithDisplayName:(NSString *)displayName
                    withOwnMCPeerID:(MCPeerID *)ownMCPeerID
                    withOwnMHPeerID:(NSString *)ownMHPeerID
                       withMCPeerID:(MCPeerID *)mcPeerID
                       withMHPeerID:(NSString *)mhPeerID
{
    self = [super init];
    if (self)
    {
        self.nbHeartbeatFails = 0;
        self.heartbeatStarted = NO;
        
        self.displayName = displayName;
        self.mcPeerID = mcPeerID;
        self.mhPeerID = mhPeerID;
        
        if (![ownMCPeerID isEqual:mcPeerID]) // if it is not the owner mhPeer we create a session
        {
            self.session = [[MCSession alloc] initWithPeer:ownMCPeerID
                                          securityIdentity:nil
                                      encryptionPreference:MCEncryptionRequired];
            self.session.delegate = self;
            
            
            self.peerBuffer = [[MHPeerBuffer alloc] initWithMCSession:self.session];
            
            // Heartbeat mechanism
            MHPeer * __weak weakSelf = self;
            
            // We send heartbeat messages only one way
            if ([ownMHPeerID compare:self.mhPeerID] == NSOrderedAscending)
            {
                self.HeartbeatSender = YES;
            }
            else
            {
                self.HeartbeatSender = NO;
            }
            
            
            if (self.HeartbeatSender)
            {
                [self setFctProcessHeartbeatSender:weakSelf];
            }
            else
            {
                [self setFctProcessHeartbeatReceiver:weakSelf];
            }
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MHPEER_STARTHEARTBEAT_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(weakSelf)
                {
                    // No connection callback has yet been executed (MC bug)
                    // Try determining connection by heartbeat
                    [weakSelf startHeartbeat:weakSelf];
                }
            });
        }
    }
    return self;
}


- (void)dealloc
{
    [self disconnect];
    self.session = nil;
    self.mcPeerID = nil;
    self.peerBuffer = nil;
}


- (void)setFctProcessHeartbeatSender:(MHPeer * __weak)weakSelf
{
    // Sender side
    self.processHeartbeat = ^{
        if(weakSelf)
        {
            weakSelf.nbHeartbeatFails++;
            
            // The heartbeat fails for x times, then disconnect
            if (weakSelf.nbHeartbeatFails > MHPEER_MAX_HEARTBEAT_FAILS)
            {
                [weakSelf setConnectionDisabled:weakSelf withReason:@"Heartbeat failed"];
            }
            else
            {
                NSError *error;
                
                MHDatagram *datagram = [[MHDatagram alloc] initWithData:[MHComputation emptyData]];
                [datagram.info setObject:@"" forKey:MHPEER_HEARTBEAT_MSG];
                
                [weakSelf.session sendData:[datagram asNSData]
                                   toPeers:weakSelf.session.connectedPeers
                                  withMode:MCSessionSendDataUnreliable
                                     error:&error];
                
                
                // Dispatch after y seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MHPEER_HEARTBEAT_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
            }
        }
    };
}

- (void)setFctProcessHeartbeatReceiver:(MHPeer * __weak)weakSelf
{
    // Receiver side
    self.processHeartbeat = ^{
        if(weakSelf)
        {
            weakSelf.nbHeartbeatFails++;
            
            // The heartbeat fails for x times, then disconnect
            if (weakSelf.nbHeartbeatFails > MHPEER_MAX_HEARTBEAT_FAILS)
            {
                [weakSelf setConnectionDisabled:weakSelf withReason:@"Heartbeat failed"];
            }
            else
            {
                // Dispatch after y seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MHPEER_HEARTBEAT_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
            }
        }
    };
}

- (void)startHeartbeat:(MHPeer * __weak)weakSelf
{
    if (!weakSelf.heartbeatStarted)
    {
        weakSelf.heartbeatStarted = YES;
        
        // Dispatch after y seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MHPEER_HEARTBEAT_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
    }
}

- (void)disconnect
{
    self.connected = NO;
    // Will clean up the session properly
    [self.session disconnect];
}


- (void)sendDatagram:(MHDatagram *)datagram
               error:(NSError **)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.peerBuffer pushDatagram:datagram];
    });
}


#pragma mark - Session Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(state == MCSessionStateNotConnected) {
        // We cannot rely on this callback!! In certain environments,
        // it is called continously even if the peers are actually conected
        //[self setConnectionDisabled:self withReason:@"Session disconnection"];
    }
    else if(state == MCSessionStateConnected)
    {
        [self startHeartbeat:self];
        [self setConnectionEnabled];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    MHDatagram *datagram = [MHDatagram fromNSData:data];
    NSLog([NSString stringWithFormat:@"%d", data.length]);
    
    if ([datagram.info objectForKey:MHPEER_HEARTBEAT_MSG] != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nbHeartbeatFails = 0;
            
            [self setConnectionEnabled];
            
            // Heartbeat replication (ack)
            NSError *error;
            MHDatagram *datagram = [[MHDatagram alloc] initWithData:[MHComputation emptyData]];
            [datagram.info setObject:@"" forKey:MHPEER_ACK_MSG];
            
            [self.session sendData:[datagram asNSData]
                           toPeers:self.session.connectedPeers
                          withMode:MCSessionSendDataUnreliable
                             error:&error];
        });
    }
    else if ([datagram.info objectForKey:MHPEER_ACK_MSG] != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Reset the heartbeat fail counter
            self.nbHeartbeatFails = 0;
            
            [self setConnectionEnabled];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate mhPeer:self didReceiveDatagram:datagram];
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


#pragma mark - Connection helper methods
- (void)setConnectionEnabled
{
    if (!self.connected)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connected = YES;
            [self.peerBuffer setConnected];
            [self.delegate mhPeer:self hasConnected:@"Connected"];
        });
    }
}

- (void)setConnectionDisabled:(MHPeer * __weak)weakSelf withReason:(NSString *)reason
{
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.connected = NO;
        [self.peerBuffer setDisconnected];
        [weakSelf.delegate mhPeer:weakSelf hasDisconnected:reason];
    });
}


# pragma mark - Static methods

+ (MHPeer *)getOwnMHPeerWithDisplayName:(NSString *)displayName
{
    NSString *mhPeerID = [[NSUserDefaults standardUserDefaults] valueForKey:@"MultihopID"];
    
    if(mhPeerID == nil)
    {
        // Generation of a new PeerID
        mhPeerID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:mhPeerID forKey:@"MultihopID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    MCPeerID *mcPeerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    return [[MHPeer alloc] initWithDisplayName:displayName
                               withOwnMCPeerID:mcPeerID
                               withOwnMHPeerID:@""
                                  withMCPeerID:mcPeerID
                                  withMHPeerID:mhPeerID];
}


@end
