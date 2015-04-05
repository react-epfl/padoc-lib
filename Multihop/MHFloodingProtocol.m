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
        [self.cHandler connectToAll];
    }
    return self;
}

- (void)dealloc
{
    self.processedPackets = nil;
}



- (void)discover
{
    MHPacket *discoverRequestPacket = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                                      withDestinations:[[NSArray alloc] init]
                                                              withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [discoverRequestPacket.info setObject:[NSNumber numberWithInt:5] forKey:@"ttl"];
    [discoverRequestPacket.info setObject:@"YES" forKey:@"discover-request"];
    [self.processedPackets addObject:discoverRequestPacket.tag];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        [self.cHandler sendData:[discoverRequestPacket asNSData] toPeers:self.neighbourPeers error:&error];
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
    [packet.info setObject:[NSNumber numberWithInt:5] forKey:@"ttl"];
    
    [self.processedPackets addObject:packet.tag];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhProtocol:self isDiscovered:@"Discovered" peer:peer displayName:displayName];
    });
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
    
    if (![self.processedPackets containsObject:packet.tag])
    {
        [self.processedPackets addObject:packet.tag];
        
        
        
        if ([packet.info objectForKey:@"discover-request"] != nil && ![self.neighbourPeers containsObject:packet.source])
        {
            MHPacket *discoverResponsePacket = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                                               withDestinations:[[NSArray alloc] initWithObjects:packet.source, nil]
                                                                       withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [discoverResponsePacket.info setObject:[NSNumber numberWithInt:5] forKey:@"ttl"];
            [discoverResponsePacket.info setObject:@"YES" forKey:@"discover-response"];
            [discoverResponsePacket.info setObject:self.displayName forKey:@"displayname"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                [self.cHandler sendData:[discoverResponsePacket asNSData] toPeers:self.neighbourPeers error:&error];
            });
        }
        
        if ([packet.info objectForKey:@"discover-response"] != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self isDiscovered:@"Discovered" peer:packet.source displayName:[packet.info objectForKey:@"displayname"]];
            });
            
            return;
        }
        
        
        if ([packet.destinations containsObject:[self getOwnPeer]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self didReceivePacket:packet];
            });
        }
        
        int ttl = [[packet.info objectForKey:@"ttl"] intValue];
        ttl--;
        
        if (ttl > 0)
        {
            [packet.info setObject:[NSNumber numberWithInt:ttl] forKey:@"ttl"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                NSMutableArray *targets = [[NSMutableArray alloc] initWithArray:self.neighbourPeers copyItems:YES];
                [targets removeObject:peer];
                
                [self.cHandler sendData:[packet asNSData] toPeers:targets error:&error];
            });
        }
    }
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
  enteredStandby:(NSString *)info
            peer:(NSString *)peer
{
    
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
   leavedStandby:(NSString *)info
            peer:(NSString *)peer
{
    
}


@end