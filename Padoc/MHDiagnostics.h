/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHDiagnosticsOptions_h
#define Padoc_MHDiagnosticsOptions_h


#import <Foundation/Foundation.h>
#import "MHPacket.h"

#define MH_DIAGNOSTICS_TRACE  @"[{_-diagnostics-trace-_}]"


@interface MHDiagnostics : NSObject

@property (nonatomic, readwrite) BOOL useTraceInfo;
@property (nonatomic, readwrite) BOOL useRetransmissionInfo;
@property (nonatomic, readwrite) BOOL useNeighbourInfo;
@property (nonatomic, readwrite) BOOL useNetworkLayerInfoCallbacks;
@property (nonatomic, readwrite) BOOL useNetworkLayerControlInfoCallbacks;
@property (nonatomic, readwrite) BOOL useNetworkMap;


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


#pragma mark - Network map
- (BOOL)isConnectedInNetworkMap:(NSString *)localNode withNeighbourNode:(NSString *)neighbourNode;
   
// Callable by developer
- (void)addNetworkMapNode:(NSString *)currentNode withConnectedNodes:(NSArray *)connectedNodes;
- (void)clearNetworkMap;

@end


#endif
