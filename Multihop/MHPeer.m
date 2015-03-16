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

@end

@implementation MHPeer

#pragma mark - Life Cycle

- (instancetype)init:(NSString *)displayName
     withOwnMCPeerID:(MCPeerID *)ownMCPeerID
        withMCPeerID:(MCPeerID *)mcPeerID
        withMHPeerID:(NSString *)mhPeerID
{
    self = [super init];
    if (self)
    {
        self.displayName = displayName;
        self.mcPeerID = mcPeerID;
        self.mhPeerID = mhPeerID;
        
        self.session = [[MCSession alloc] initWithPeer:ownMCPeerID
                                      securityIdentity:nil
                                  encryptionPreference:MCEncryptionRequired];
        self.session.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    // Will clean up the session properly
    self.session = nil;
    self.mcPeerID = nil;
}

#pragma mark - Membership

#pragma mark - Session Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"Peer [%@] changed state to %@ numbers of connected %lu", peerID.displayName, [self stringForPeerConnectionState:state], (unsigned long)self.connectedPeers.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate partyTime:self peer:peerID changedState:state currentPeers:self.session.connectedPeers];
    });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(partyTime:didReceiveData:fromPeer:)])
        {
            [self.delegate partyTime:self didReceiveData:data fromPeer:peerID];
        }
    });
}


// Required because of an apple bug
- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}

@end
