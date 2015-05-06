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

- (instancetype)init;

+ (MHDiagnostics*)getSingleton;

#pragma mark - Tracing methods
- (void)addTraceRoute:(MHPacket*)packet withNextPeer:(NSString*)peer;
- (NSArray *)tracePacket:(MHPacket*)packet;

@end


#endif
