//
//  MHNodeManager.m
//  Multihop
//
//  Created by quarta on 16/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHMultipeerWrapper.h"


@interface MHMultipeerWrapper () <MHPeerDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

// Public Properties
@property (nonatomic, readwrite) BOOL connected;
@property (nonatomic, readwrite) BOOL acceptingGuests;
@property (nonatomic, readwrite, strong) NSString *serviceType;

@property (nonatomic, strong) MHPeer *mhPeer;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) NSDictionary *dictInfo;

@end

@implementation MHMultipeerWrapper

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name];
}

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.serviceType = [NSString stringWithFormat:@"multihop_%@", serviceType];
        self.mhPeer = [MHPeer getOwnMHPeerWithDisplayName:displayName];
    }
    return self;
}

- (void)dealloc
{
    // Will clean up the session and browsers properly
    [self disconnectFromAll];
}

#pragma mark - Membership

- (void)connectToAll
{
    // If we're already joined, then don't try again. This causes crashes.
    
    if (!self.acceptingGuests)
    {
        // Simultaneously advertise and browse at the same time
        [self.advertiser startAdvertisingPeer];
        [self.browser startBrowsingForPeers];
        
        self.connected = YES;
        self.acceptingGuests = YES;
    }
}

- (void)stopAcceptingConnections
{
    if (self.acceptingGuests)
    {
        [self.advertiser stopAdvertisingPeer];
        [self.browser stopBrowsingForPeers];
        self.acceptingGuests = NO;
    }
}

- (void)disconnectFromAll
{
    [self stopAcceptingConnections];
    
    // Must nil out these because if we try to reconnect, we need to recreate them
    // Else it fails to connect
// TODO: peer?
    self.advertiser = nil;
    self.browser = nil;
    self.connected = NO;
}

#pragma mark - Communicate

- (void)sendData:(NSData *)data
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error
{
    for (id peerObj in self.connectedPeers)
    {
        MHPeer *peer = (MHPeer *)peerObj;
        
        [peer.session sendData:data
                       toPeers:peer.session.connectedPeers
                      withMode:mode
                         error:error];
    }
}

- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error
{
    for (id peerObj in peers)
    {
        MHPeer *peer = [self getMHPeerFromId:(NSString *)peerObj];
        
        [peer.session sendData:data
                       toPeers:peer.session.connectedPeers
                      withMode:mode
                         error:error];
    }
}



#pragma mark - Properties

- (NSDictionary *)dictInfo
{
    if (!_dictInfo)
    {
        NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
        
        _dictInfo = [[NSDictionary alloc] init];
        [_dictInfo setValue:self.mhPeer.mhPeerID forUndefinedKey:@"MultihopID"];
        [_dictInfo setValue:self.mhPeer.displayName forUndefinedKey:@"MultihopDisplayName"];
    }
    return _dictInfo;
}

- (MCNearbyServiceAdvertiser *)advertiser
{
    if (!_advertiser)
    {
        NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
        
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.mhPeer.mcPeerID
                                                        discoveryInfo:self.dictInfo
                                                          serviceType:self.serviceType];
        _advertiser.delegate = self;
    }
    return _advertiser;
}


- (MCNearbyServiceBrowser *)browser
{
    if (!_browser)
    {
        NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.mhPeer.mcPeerID
                                                    serviceType:self.serviceType];
        _browser.delegate = self;
    }
    return _browser;
}

#pragma mark - MHPeer Delegate

- (void)mhPeer:(MHPeer *)mhPeer changedState:(MCSessionState)state
{
 /*   NSLog(@"Peer [%@] changed state to %@ numbers of connected %lu", peerID.displayName, [self stringForPeerConnectionState:state], (unsigned long)self.connectedPeers.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate partyTime:self peer:peerID changedState:state currentPeers:self.session.connectedPeers];
    });*/
}

- (void)mhPeer:(MHPeer *)mhPeer didReceiveData:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mcWrapper:didReceiveData:fromPeer:)])
        {
            [self.delegate mcWrapper:self didReceiveData:data fromPeer:mhPeer.mhPeerID];
        }
    });
}


#pragma mark - Advertiser Delegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    // Only accept invitations with IDs lower than the current host
    // If both people accept invitations, then connections are lost
    // However, this should always be the case since we only send invites in one direction
    NSDictionary *info = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:context];
    
    if ([self.mhPeer.mhPeerID compare:[info valueForKey:@"MultihopID"]] == NSOrderedDescending)
    {
        MHPeer *peer = [[MHPeer alloc] initWithDisplayName:[info valueForKey:@"MultihopDisplayName"] withOwnMCPeerID:self.mhPeer.mcPeerID withMCPeerID:peerID withMHPeerID:[info valueForKey:@"MultihopID"]];
        
        [self.connectedPeers setValue:peer forUndefinedKey:peer.mhPeerID];
        
        invitationHandler(YES, peer.session);
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    [self.delegate mcWrapper:self failedToConnect:error];
}

#pragma mark - Browser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    // Whenever we find a peer, let's just send them an invitation
    // But only send invites one way
    // TODO: check if peer already connected
    // TODO: Make timeout configurable
    if ([self.mhPeer.mhPeerID compare:[info valueForKey:@"MultihopID"]] == NSOrderedAscending)
    {
        MHPeer *peer = [[MHPeer alloc] initWithDisplayName:[info valueForKey:@"MultihopDisplayName"] withOwnMCPeerID:self.mhPeer.mcPeerID withMCPeerID:peerID withMHPeerID:[info valueForKey:@"MultihopID"]];
        
        [self.connectedPeers setValue:peer forUndefinedKey:peer.mhPeerID];
        
        
        NSData *context = [NSKeyedArchiver archivedDataWithRootObject:self.dictInfo];
        
        NSLog(@"Sending invite: Self: %@", self.mhPeer.displayName);
        [browser invitePeer:peerID
                  toSession:peer.session
                withContext:context
                    timeout:10];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Lost a peer");
    // Ignore this. We don't need it.
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    [self.delegate mcWrapper:self failedToConnect:error];
}

         
#pragma mark - Helper methods
- (MHPeer *)getMHPeerFromId:(NSString *)peerID
{
    return [self.connectedPeers valueForKey:peerID];
}


@end
