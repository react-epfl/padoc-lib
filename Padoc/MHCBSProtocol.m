/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
    
    // If packet is received for the first time, the forward boolean
    // is set to true, otherwise to false
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.forwardPackets setObject:[NSNumber numberWithBool:!([self.processedPackets containsObject:packet.tag])] forKey:packet.tag];
    });
    
    [super processStandardPacket:packet];
}


- (void)forwardPacket:(MHPacket*)packet
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random_uniform(([MHConfig getSingleton].netCBSPacketForwardDelayRange) + [MHConfig getSingleton].netCBSPacketForwardDelayBase) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        NSNumber *forward = [self.forwardPackets objectForKey:packet.tag];
        
        // We only forward if the same packet has not been received
        // again during the delay
        if (!forward || (forward && [forward boolValue]))
        {
            [super forwardPacket:packet];
        }
    });
}

@end