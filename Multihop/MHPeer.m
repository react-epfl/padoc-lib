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

@property (nonatomic, readwrite, strong) NSString *displayName;

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *mcPeerID;
@property (nonatomic, strong) NSString *mhPeerID;
@property (nonatomic) int nbHeartbeatFails;

@property (nonatomic, strong) NSString *HeartbeatMsg;
@property (nonatomic, strong) NSString *AckMsg;

@property (nonatomic) int HeartbeatTimeBase;
@property (nonatomic) int HeartbeatTimeRange;
@property (nonatomic) int MaxHeartbeatFails;

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
        
        self.HeartbeatTimeBase = 1;
        self.HeartbeatTimeRange = 1;
        self.MaxHeartbeatFails = 3;
        
        self.HeartbeatMsg = @"[{_-heartbeat-_}]";
        self.AckMsg = @"[{_-ack-_}]";
        
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
                self.processHeartbeat = ^{
                    weakSelf.nbHeartbeatFails++;
                    
                    // The heartbeat fails for x times, then disconnect
                    if (weakSelf.nbHeartbeatFails > weakSelf.MaxHeartbeatFails)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate mhPeer:weakSelf hasDisconnected:@"Disconnected"];
                            weakSelf.connected = NO;
                        });
                    }
                    else
                    {
                        NSError *error;
                        
                        NSLog(@"sending heartbeat");
                        
                        if(weakSelf.connected)
                        {
                            [weakSelf.session sendData:[weakSelf.HeartbeatMsg dataUsingEncoding:NSUTF8StringEncoding] toPeers:weakSelf.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
                            
                            
                            // Dispatch after y seconds
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(weakSelf.HeartbeatTimeRange) + weakSelf.HeartbeatTimeBase) * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
                        }
                    }
                };
            }
            else
            {
                self.processHeartbeat = ^{
                    weakSelf.nbHeartbeatFails++;
                    
                    // The heartbeat fails for x times, then disconnect
                    if (weakSelf.nbHeartbeatFails > weakSelf.MaxHeartbeatFails)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate mhPeer:weakSelf hasDisconnected:@"Disconnected"];
                            weakSelf.connected = NO;
                        });
                    }
                    else
                    {
                        if (weakSelf.connected)
                        {
                            // Dispatch after y seconds
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((weakSelf.HeartbeatTimeBase + weakSelf.HeartbeatTimeRange + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), weakSelf.processHeartbeat);
                        }
                    }
                };
            }

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
}


#pragma mark - Session Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(state == MCSessionStateNotConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate mhPeer:self hasDisconnected:@"Disconnected"];
            self.connected = NO;
        });
    }
    else if(state == MCSessionStateConnected)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate mhPeer:self hasConnected:@"Connected"];
            self.connected = YES;
            
            int delay = 0;
            
            if (self.HeartbeatSender)
            {
                delay = arc4random_uniform(self.HeartbeatTimeRange) + self.HeartbeatTimeBase;
            }
            else
            {
                delay = self.HeartbeatTimeBase + self.HeartbeatTimeRange + 1;
            }
            
            // Dispatch after y seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), self.processHeartbeat);
        });
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // TODO: find a faster way to check if it is the heartbeat msg
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([dataStr isEqualToString:self.HeartbeatMsg])
    {
        NSLog(@"received heartbeat, sending ack");
        self.nbHeartbeatFails = 0;
        
        if (self.connected)
        {
            NSError *error;
            [self.session sendData:[self.AckMsg dataUsingEncoding:NSUTF8StringEncoding] toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        }
    }
    else if ([dataStr isEqualToString:self.AckMsg])
    {
        NSLog(@"received ack");
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
    
    return [[MHPeer alloc] initWithDisplayName:displayName
                               withOwnMCPeerID:mcPeerID
                               withOwnMHPeerID:@""
                                  withMCPeerID:mcPeerID
                                  withMHPeerID:mhPeerID];
}


@end
