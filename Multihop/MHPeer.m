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
@property (nonatomic, readwrite) BOOL connected;
@property (nonatomic, readwrite) BOOL heartbeatStarted;

@property (nonatomic, readwrite, strong) NSString *displayName;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *mcPeerID;
@property (nonatomic, strong) NSString *mhPeerID;
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
                
                if(weakSelf.connected)
                {
                    [weakSelf.session sendData:[MHPEER_HEARTBEAT_MSG dataUsingEncoding:NSUTF8StringEncoding] toPeers:weakSelf.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
                    
                    
                    // Dispatch after y seconds
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(MHPEER_HEARTBEAT_TIME_RANGE) + MHPEER_HEARTBEAT_TIME_BASE) * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
                }
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
                if (weakSelf.connected)
                {
                    // Dispatch after y seconds
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((MHPEER_HEARTBEAT_TIME_BASE + MHPEER_HEARTBEAT_TIME_RANGE + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
                }
            }
        }
    };
}

- (void)startHeartbeat:(MHPeer * __weak)weakSelf
{
    if (!weakSelf.heartbeatStarted)
    {
        int delay = 0;
        weakSelf.heartbeatStarted = YES;
        
        // After connection, start heartbeat mechanism
        if (weakSelf.HeartbeatSender)
        {
            delay = arc4random_uniform(MHPEER_HEARTBEAT_TIME_RANGE) + MHPEER_HEARTBEAT_TIME_BASE;
        }
        else
        {
            delay = MHPEER_HEARTBEAT_TIME_BASE + MHPEER_HEARTBEAT_TIME_RANGE + 1;
        }
        
        // Dispatch after y seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
    }
}

- (void)disconnect
{
    self.connected = NO;
    // Will clean up the session properly
    [self.session disconnect];
}


- (void)sendData:(NSData *)data
        reliable:(BOOL)reliable
           error:(NSError **)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connected)
        {
            MCSessionSendDataMode mode;
            
            if (reliable)
            {
                mode = MCSessionSendDataReliable;
            }
            else
            {
                mode = MCSessionSendDataUnreliable;
            }
            
            [self.session sendData:data
                           toPeers:self.session.connectedPeers
                          withMode:mode
                             error:error];
        }
    });
}


#pragma mark - Session Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(state == MCSessionStateNotConnected) {
        [self setConnectionDisabled:self withReason:@"Session disconnection"];
    }
    else if(state == MCSessionStateConnected)
    {
        [self startHeartbeat:self];
        [self setConnectionEnabled];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([dataStr isEqualToString:MHPEER_HEARTBEAT_MSG])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nbHeartbeatFails = 0;
            
            [self setConnectionEnabled];
            
            // Heartbeat replication (ack)
            NSError *error;
            [self.session sendData:[MHPEER_ACK_MSG dataUsingEncoding:NSUTF8StringEncoding]
                           toPeers:self.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
        });
    }
    else if ([dataStr isEqualToString:MHPEER_ACK_MSG])
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
            [self.delegate mhPeer:self didReceiveData:data];
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
            [self.delegate mhPeer:self hasConnected:@"Connected"];
        });
    }
}

- (void)setConnectionDisabled:(MHPeer * __weak)weakSelf withReason:(NSString *)reason
{
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.connected = NO;
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
