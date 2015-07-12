//
//  MHCBSProtocol.m
//  Multihop
//
//  Created by quarta on 23/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//



#import "MHCBSProtocol.h"



@interface MHCBSProtocol ()

@property (nonatomic, strong) NSMutableArray *neighbourPeers;
@property (nonatomic, strong) MHConnectionsHandler *cHandler;


@property (nonatomic, strong) NSMutableArray *processedPackets;
@property (nonatomic, strong) NSMutableDictionary *forwardPackets;

@property (copy) void (^forwardPacketsCleaning)(void);

@end

@implementation MHCBSProtocol

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super initWithServiceType:serviceType displayName:displayName];
    
    if (self)
    {
        self.forwardPackets = [[NSMutableDictionary alloc] init];
        
        MHCBSProtocol * __weak weakSelf = self;
        [self setFctForwardPacketsCleaning:weakSelf];
    }
    
    return self;
}

- (void)dealloc
{
    self.processedPackets = nil;
    self.forwardPackets = nil;
    
    self.forwardPacketsCleaning = nil;
}

- (void)setFctForwardPacketsCleaning:(MHCBSProtocol * __weak)weakSelf
{
    self.forwardPacketsCleaning = ^{
        if (weakSelf)
        {
            [weakSelf.forwardPackets removeAllObjects];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([MHConfig getSingleton].netProcessedPacketsCleaningDelay * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.forwardPacketsCleaning);
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([MHConfig getSingleton].netProcessedPacketsCleaningDelay * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.forwardPacketsCleaning);
}


#pragma mark - ConnectionsHandler delegate methods
- (void)cHandler:(MHConnectionsHandler *)cHandler
didReceiveDatagram:(MHDatagram *)datagram
        fromPeer:(NSString *)peer
{
    MHPacket *packet = [MHPacket fromNSData:datagram.data];
    
    // If packet has not yet been processed

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.forwardPackets setObject:[NSNumber numberWithBool:!([self.processedPackets containsObject:packet.tag])] forKey:packet.tag];
    });
    
    [super processStandardPacket:packet];
}


- (void)forwardPacket:(MHPacket*)packet
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random_uniform(([MHConfig getSingleton].netCBSPacketForwardDelayRange) + [MHConfig getSingleton].netCBSPacketForwardDelayBase) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        NSNumber *forward = [self.forwardPackets objectForKey:packet.tag];
        
        if (!forward || (forward && [forward boolValue]))
        {
            [super forwardPacket:packet];
        }
    });
}

@end