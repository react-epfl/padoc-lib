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

@property (nonatomic, strong) NSMutableArray *processedPackets;
@property (nonatomic, strong) NSString *displayName;

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
        self.processedPackets = [[NSMutableArray alloc] init];
        [self.cHandler connectToNeighbourhood];
    }
    return self;
}

- (void)dealloc
{
    self.processedPackets = nil;
}



- (void)discover
{
    MHPacket *discoverMeRequestPacket = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                                        withDestinations:[[NSArray alloc] init]
                                                                withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [discoverMeRequestPacket.info setObject:@"YES" forKey:MH_FLOODING_DISCOVERME_MSG];
    [discoverMeRequestPacket.info setObject:self.displayName forKey:@"displayname"];
    
    // Broadcast discovery-me request
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        [self sendPacket:discoverMeRequestPacket error:&error];
    });
}

- (void)disconnect
{
    [self.processedPackets removeAllObjects];
    [super disconnect];
}

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    // Set ttl
    [packet.info setObject:[NSNumber numberWithInt:MH_FLOODING_TTL] forKey:@"ttl"];
    
    // Add to processed packets list
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.processedPackets addObject:packet.tag];
    });
    
    // Broadcast
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:error];
    });
}




#pragma mark - ConnectionsHandler delegate methods
- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
    [self.neighbourPeers addObject:peer];
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    [self.neighbourPeers removeObject:peer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhProtocol:self hasDisconnected:info peer:peer];
    });
}


- (void)cHandler:(MHConnectionsHandler *)cHandler
  didReceiveData:(NSData *)data
        fromPeer:(NSString *)peer
{
    MHPacket *packet = [MHPacket fromNSData:data];
    
    // If packet has not yet been processed
    if (![self.processedPackets containsObject:packet.tag])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.processedPackets addObject:packet.tag];
        });
        
        
        // It's a discover-me request
        if ([packet.info objectForKey:MH_FLOODING_DISCOVERME_MSG] != nil)
        {
            // Notify upper layers of the new discovery
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self isDiscovered:@"Discovered" peer:packet.source displayName:[packet.info objectForKey:@"displayname"]];
            });
        }
        
        if ([packet.destinations containsObject:[self getOwnPeer]])
        {
            // Notify upper layers that a new packet is received
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self didReceivePacket:packet];
            });
        }
        
        
        // For any packet, forwarding phase
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

- (void)cHandler:(MHConnectionsHandler *)cHandler
  enteredStandby:(NSString *)info
            peer:(NSString *)peer
{
    // We do not care about
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
   leavedStandby:(NSString *)info
            peer:(NSString *)peer
{
    // We do not care about
}


@end