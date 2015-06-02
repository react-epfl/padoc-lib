//
//  MHFloodingProtocol.m
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHFloodingProtocol.h"



@interface MHFloodingProtocol ()

@property (nonatomic, strong) NSMutableArray *neighbourPeers;
@property (nonatomic, strong) MHConnectionsHandler *cHandler;

@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, strong) NSMutableArray *processedPackets;

@property (nonatomic, strong) NSMutableDictionary *discoveryPackets;
@property (nonatomic, strong) MHPacket *ownDiscoveryPacket;

@property (copy) void (^processedPacketsCleaning)(void);

@end

@implementation MHFloodingProtocol

#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super initWithServiceType:serviceType displayName:displayName];
    if (self)
    {
        self.displayName = displayName;
        self.discoveryPackets = [[NSMutableDictionary alloc] init];
        self.processedPackets = [[NSMutableArray alloc] init];
        [self.cHandler connectToNeighbourhood];
        
        MHFloodingProtocol * __weak weakSelf = self;
        [self setFctProcessedPacketsCleaning:weakSelf];
    }
    return self;
}

- (void)dealloc
{
    self.processedPackets = nil;
    self.discoveryPackets = nil;
}



- (void)setFctProcessedPacketsCleaning:(MHFloodingProtocol * __weak)weakSelf
{
    self.processedPacketsCleaning = ^{
        if (weakSelf)
        {
            [weakSelf.processedPackets removeAllObjects];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_FLOODING_SCHEDULECLEANING_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.processedPacketsCleaning);
        }
    };
    
    // Every x seconds, we clean the processed packets list
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_FLOODING_SCHEDULECLEANING_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.processedPacketsCleaning);
}



- (MHPacket*)ownDiscoveryPacket
{
    if (!_ownDiscoveryPacket)
    {
        _ownDiscoveryPacket = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                              withDestinations:[[NSArray alloc] init]
                                                      withData:[MHComputation emptyData]];
    
        // Adding discovery information and ttl
        [_ownDiscoveryPacket.info setObject:@"YES" forKey:MH_FLOODING_DISCOVERME_MSG];
        [_ownDiscoveryPacket.info setObject:self.displayName forKey:@"displayname"];
        [_ownDiscoveryPacket.info setObject:[NSNumber numberWithInt:MH_FLOODING_TTL] forKey:@"ttl"];
    }
    
    return _ownDiscoveryPacket;
}

- (void)disconnect
{
    [self.processedPackets removeAllObjects];
    [self.discoveryPackets removeAllObjects];
    [super disconnect];
}

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    // Diagnostics: trace
    [[MHDiagnostics getSingleton] addTraceRoute:packet withNextPeer:[self getOwnPeer]];
    
    // Set ttl
    [packet.info setObject:[NSNumber numberWithInt:MH_FLOODING_TTL] forKey:@"ttl"];
    
    // Broadcast
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:error];
    });
}


- (int)hopsCountFromPeer:(NSString*)peer
{
    return 0;
}


#pragma mark - ConnectionsHandler delegate methods
- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
    [self.neighbourPeers addObject:peer];
    
    // Sending of the own discovery packet
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        [self.cHandler sendData:[[self ownDiscoveryPacket] asNSData]
                        toPeers:[[NSArray alloc] initWithObjects:peer, nil]
                          error:&error];
    });
    
    // Forwarding of every stored discovery packet
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *discPacketKeys = [self.discoveryPackets allKeys];
        for (id discPacketKey in discPacketKeys)
        {
            MHPacket *discPacket = [self.discoveryPackets objectForKey:discPacketKey];
            
            // Diagnostics
            if ([MHDiagnostics getSingleton].useNetworkLayerInfoCallbacks &&
                [MHDiagnostics getSingleton].useNetworkDiscoveryForwardingInfoCallbacks)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate mhProtocol:self forwardPacket:@"Discovery forwarding" fromSource:discPacket.source];
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                [self.cHandler sendData:[discPacket asNSData]
                                toPeers:[[NSArray alloc] initWithObjects:peer, nil]
                                  error:&error];
            });
        }
    });
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    [self.neighbourPeers removeObject:peer];
    [self.discoveryPackets removeObjectForKey:peer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MHUnicastRoutingProtocolDelegate>)self.delegate mhProtocol:self hasDisconnected:info peer:peer];
    });
}


- (void)cHandler:(MHConnectionsHandler *)cHandler
  didReceiveData:(NSData *)data
        fromPeer:(NSString *)peer
{
    MHPacket *packet = [MHPacket fromNSData:data];
    
    // It's a discover-me request
    if ([packet.info objectForKey:MH_FLOODING_DISCOVERME_MSG] != nil)
    {
        [self processDiscoveryPacket:packet];
    }
    else
    {
        [self processStandardPacket:packet];
    }
}


-(void)processDiscoveryPacket:(MHPacket*)packet
{
    // Do not process packets whose source is this peer
    if ([packet.source isEqualToString:[self getOwnPeer]])
    {
        return;
    }
    
    // Check if discovery packet already processed
    if ([self.discoveryPackets objectForKey:packet.source] == nil)
    {
        // If not, we notify upper layers of the new discovery
        // and forward it
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.discoveryPackets setObject:packet forKey:packet.source];
            [(id<MHUnicastRoutingProtocolDelegate>)self.delegate mhProtocol:self
                                                               isDiscovered:@"Discovered"
                                                                       peer:packet.source
                                                                displayName:[packet.info objectForKey:@"displayname"]];
        });
        
        // Diagnostics
        if ([MHDiagnostics getSingleton].useNetworkLayerInfoCallbacks &&
            [MHDiagnostics getSingleton].useNetworkDiscoveryForwardingInfoCallbacks)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self forwardPacket:@"Discovery forwarding" fromSource:packet.source];
            });
        }
        
        [self forwardPacket:packet];
    }
}

-(void)processStandardPacket:(MHPacket*)packet
{
    // Diagnostics: trace
    [[MHDiagnostics getSingleton] addTraceRoute:packet withNextPeer:[self getOwnPeer]];
    
    // Diagnostics: retransmission
    [[MHDiagnostics getSingleton] increaseReceivedPackets];
    
    // Do not process packets whose source is this peer
    if ([packet.source isEqualToString:[self getOwnPeer]])
    {
        return;
    }
    
    // If packet has not yet been processed
    if (![self.processedPackets containsObject:packet.tag])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.processedPackets addObject:packet.tag];
        });
        
        if ([packet.destinations containsObject:[self getOwnPeer]])
        {
            // Notify upper layers that a new packet is received
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self didReceivePacket:packet withTraceInfo:[[MHDiagnostics getSingleton] tracePacket:packet]];
            });
        }
        
        // Diagnostics: retransmission
        [[MHDiagnostics getSingleton] increaseRetransmittedPackets];
        
        // For any packet, forwarding phase
        // Diagnostics
        if ([MHDiagnostics getSingleton].useNetworkLayerInfoCallbacks)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self forwardPacket:@"Packet forwarding" fromSource:packet.source];
            });
        }
        
        [self forwardPacket:packet];
    }
}


- (void)forwardPacket:(MHPacket*)packet
{
    // Decrease the ttl
    int ttl = [[packet.info objectForKey:@"ttl"] intValue];
    ttl--;
    
    // If packet is still valid
    if (ttl > 0)
    {
        // Update ttl
        [packet.info setObject:[NSNumber numberWithInt:ttl] forKey:@"ttl"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Broadcast to neighbourhood
            NSError *error;
            [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
        });
    }
}

@end