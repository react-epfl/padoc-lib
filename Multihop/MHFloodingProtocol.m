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
@property (nonatomic, strong) NSString *ownPeer;
@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, strong) NSMutableArray *processedPackets;

@end

@implementation MHFloodingProtocol

#pragma mark - Initialization
- (instancetype)initWithPeer:(NSString *)peer withDisplayName:(NSString *)displayName
{
    self = [super initWithPeer:peer withDisplayName:displayName];
    if (self)
    {
        self.processedPackets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.processedPackets = nil;
}


- (void)callSpecialRoutingFunctionWithName:(NSString *)name withArgs:(NSDictionary *)args
{
    // No special functions supported
}

- (void)discover
{
    MHPacket *discoverRequestPacket = [[MHPacket alloc] initWithSource:self.ownPeer
                                                      withDestinations:[[NSArray alloc] init]
                                                              withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [discoverRequestPacket.info setObject:[NSNumber numberWithInt:5] forKey:@"ttl"];
    [discoverRequestPacket.info setObject:@"YES" forKey:@"discover-request"];
    [self.processedPackets addObject:discoverRequestPacket.tag];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        [self.delegate mhProtocol:self sendPacket:discoverRequestPacket toPeers:self.neighbourPeers error:&error];
    });
}

- (void)disconnect
{
    [super disconnect];
    [self.processedPackets removeAllObjects];
}

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    [packet.info setObject:[NSNumber numberWithInt:5] forKey:@"ttl"];
    
    [self.processedPackets addObject:packet.tag];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhProtocol:self sendPacket:packet toPeers:self.neighbourPeers error:error];
    });
}




#pragma mark - ConnectionsHandler methods
- (void)hasConnected:(NSString *)info
                peer:(NSString *)peer
         displayName:(NSString *)displayName
{
    [super hasConnected:info peer:peer displayName:displayName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhProtocol:self isDiscovered:@"Discovered" peer:peer displayName:displayName];
    });
}

- (void)hasDisconnected:(NSString *)info
                   peer:(NSString *)peer
{
    [super hasDisconnected:info peer:peer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhProtocol:self hasDisconnected:info peer:peer];
    });
}


- (void)didReceivePacket:(MHPacket *)packet
                fromPeer:(NSString *)peer
{
    if (![self.processedPackets containsObject:packet.tag])
    {
        [self.processedPackets addObject:packet.tag];
        
        
        
        if ([packet.info objectForKey:@"discover-request"] != nil && ![self.neighbourPeers containsObject:packet.source])
        {
            MHPacket *discoverResponsePacket = [[MHPacket alloc] initWithSource:self.ownPeer
                                                               withDestinations:[[NSArray alloc] initWithObjects:packet.source, nil]
                                                                       withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [discoverResponsePacket.info setObject:[NSNumber numberWithInt:5] forKey:@"ttl"];
            [discoverResponsePacket.info setObject:@"YES" forKey:@"discover-response"];
            [discoverResponsePacket.info setObject:self.displayName forKey:@"displayname"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                [self.delegate mhProtocol:self sendPacket:discoverResponsePacket toPeers:self.neighbourPeers error:&error];
            });
        }
        
        if ([packet.info objectForKey:@"discover-response"] != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self isDiscovered:@"Discovered" peer:packet.source displayName:[packet.info objectForKey:@"displayname"]];
            });
            
            return;
        }
        
        
        if ([packet.destinations containsObject:self.ownPeer])
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
                
                [self.delegate mhProtocol:self sendPacket:packet toPeers:targets error:&error];
            });
        }
    }
}

- (void)enteredStandby:(NSString *)info
                  peer:(NSString *)peer
{
    
}

- (void)leavedStandby:(NSString *)info
                 peer:(NSString *)peer
{
    
}


@end