//
//  MHDiagnosticsOptions.h
//  Multihop
//
//  Created by quarta on 05/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHDiagnosticsOptions_h
#define Multihop_MHDiagnosticsOptions_h


#import <Foundation/Foundation.h>
#import "MHPacket.h"

#define MH_DIAGNOSTICS_TRACE  @"[{_-diagnostics-trace-_}]"


@interface MHDiagnostics : NSObject

@property (nonatomic, readwrite) BOOL useTraceInfo;
@property (nonatomic, readwrite) BOOL useRetransmissionInfo;
@property (nonatomic, readwrite) BOOL useNeighbourInformartion;
@property (nonatomic, readwrite) BOOL useNetworkLayerInfoCallbacks;
@property (nonatomic, readwrite) BOOL useNetworkDiscoveryForwardingInfoCallbacks;


- (instancetype)init;

+ (MHDiagnostics*)getSingleton;

- (void)reset;

#pragma mark - Tracing methods
- (void)addTraceRoute:(MHPacket*)packet withNextPeer:(NSString*)peer;
- (NSArray *)tracePacket:(MHPacket*)packet;


#pragma mark - Retransmission methods
- (void)increaseReceivedPackets;
- (void)increaseRetransmittedPackets;

// Callable by developer
- (double)getRetransmissionRatio;


@end


#endif
