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
@property (nonatomic, readwrite) BOOL serviceStarted;
@property (nonatomic, readwrite, strong) NSString *serviceType;

@property (nonatomic, strong) MHPeer *mhPeer;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) NSMutableDictionary *dictInfo;

@property (nonatomic, strong) NSMutableDictionary *connectedPeers;
@end

@implementation MHMultipeerWrapper

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.serviceType = [NSString stringWithFormat:@"multihop-%@", serviceType];
        self.mhPeer = [MHPeer getOwnMHPeerWithDisplayName:displayName];
        self.connectedPeers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    // Will clean up the sessions and browsers properly
    [self disconnectFromAll];
}

#pragma mark - Membership

- (void)connectToAll
{
    // If we're already joined, then don't try again. This causes crashes.
    
    if (!self.serviceStarted)
    {
        // Simultaneously advertise and browse at the same time
        [self.advertiser startAdvertisingPeer];
        [self.browser startBrowsingForPeers];

        self.serviceStarted = YES;
    }
}

- (void)stopService
{
    [self.advertiser stopAdvertisingPeer];
    [self.browser stopBrowsingForPeers];
    
    // Must nil out these because if we try to reconnect, we need to recreate them
    // Else it fails to connect
    self.advertiser = nil;
    self.browser = nil;
    
    self.serviceStarted = NO;
}

- (void)disconnectFromAll
{
    if(self.serviceStarted)
    {
        [self stopService];
        
        
        for (id peerObj in self.connectedPeers)
        {
            MHPeer *peer = [self getMHPeerFromId:(NSString *)peerObj];
            
            [peer disconnect];
        }
        
        [self.connectedPeers removeAllObjects];
    }
}

#pragma mark - Communicate

- (void)sendData:(NSData *)data
        reliable:(BOOL)reliable
           error:(NSError **)error
{
    for (id peerObj in self.connectedPeers)
    {
        MHPeer *peer = [self getMHPeerFromId:(NSString *)peerObj];

        [peer sendData:data
              reliable:reliable
                 error:error];
    }
}

- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
        reliable:(BOOL)reliable
           error:(NSError **)error
{
    for (id peerObj in peers)
    {
        MHPeer *peer = [self getMHPeerFromId:(NSString *)peerObj];
        
        [peer sendData:data
              reliable:reliable
                 error:error];
    }
}

- (NSString *)getOwnPeer
{
    return self.mhPeer.mhPeerID;
}


#pragma mark - Properties

- (NSDictionary *)dictInfo
{
    if (!_dictInfo)
    {
        NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
        
        _dictInfo = [[NSMutableDictionary alloc] init];
        [_dictInfo setObject:self.mhPeer.mhPeerID forKey:@"MultihopID"];
        [_dictInfo setObject:self.mhPeer.displayName forKey:@"MultihopDisplayName"];
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

- (void)mhPeer:(MHPeer *)mhPeer hasDisconnected:(NSString *)info
{
    if ([self peerAvailable:mhPeer.mhPeerID])
    {
        NSString *mhPeerID = mhPeer.mhPeerID;
        BOOL connected = [[self getMHPeerFromId:mhPeerID] connected];
        
        [mhPeer disconnect];
        
        [self.connectedPeers removeObjectForKey:mhPeerID];
        
        // We must restarting the service, otherwise
        // the advertiser and brower do not work properly
        [self stopService];
        [self connectToAll];
        
        if (connected)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mcWrapper:self hasDisconnected:info peer:mhPeerID];
            });
        }
    }
}

- (void)mhPeer:(MHPeer *)mhPeer hasConnected:(NSString *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mcWrapper:self hasConnected:info peer:mhPeer.mhPeerID displayName:mhPeer.displayName];
    });
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
    
    if (![self peerAvailable:[info objectForKey:@"MultihopID"]] && [self.mhPeer.mhPeerID compare:[info objectForKey:@"MultihopID"]] == NSOrderedDescending)
    {
        MHPeer *peer = [[MHPeer alloc] initWithDisplayName:[info objectForKey:@"MultihopDisplayName"] withOwnMCPeerID:self.mhPeer.mcPeerID withOwnMHPeerID:self.mhPeer.mhPeerID withMCPeerID:peerID withMHPeerID:[info objectForKey:@"MultihopID"]];
        peer.delegate = self;

        [self.connectedPeers setObject:peer forKey:peer.mhPeerID];
        
        invitationHandler(YES, peer.session);
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mcWrapper:self failedToConnect:error];
    });
}

#pragma mark - Browser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    // Whenever we find a peer, let's just send them an invitation
    // But only send invites one way
    
    if (![self peerAvailable:[info objectForKey:@"MultihopID"]] && [self.mhPeer.mhPeerID compare:[info objectForKey:@"MultihopID"]] == NSOrderedAscending)
    {
        MHPeer *peer = [[MHPeer alloc] initWithDisplayName:[info objectForKey:@"MultihopDisplayName"] withOwnMCPeerID:self.mhPeer.mcPeerID withOwnMHPeerID:self.mhPeer.mhPeerID withMCPeerID:peerID withMHPeerID:[info objectForKey:@"MultihopID"]];
        peer.delegate = self;
        
        [self.connectedPeers setObject:peer forKey:peer.mhPeerID];
        
        
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
    //NSLog(@"Lost a peer");
    // Ignore this. We don't need it.
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mcWrapper:self failedToConnect:error];
    });
}

         
#pragma mark - Helper methods
- (MHPeer *)getMHPeerFromId:(NSString *)peerID
{
    MHPeer *peer = [self.connectedPeers objectForKey:peerID];
    
    if (peer == nil)
    {
        [NSException raise:@"Cannot find peer having the specified id" format:@"%@", peerID];
    }
    
    return peer;
}

- (BOOL)peerAvailable:(NSString *)peer
{
    return [self.connectedPeers objectForKey:peer] != nil;
}

@end
