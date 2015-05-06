//
//  MHDiagnosticsOptions.m
//  Multihop
//
//  Created by quarta on 05/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHDiagnostics.h"


@interface MHDiagnostics ()

@end


#pragma mark - Singleton static variables

static MHDiagnostics *diagnostics = nil;



@implementation MHDiagnostics

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.useTraceInfo = NO;
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - Singleton methods
+ (MHDiagnostics*)getSingleton
{
    if (diagnostics == nil)
    {
        // Initialize the diagnostics singleton
        diagnostics = [[MHDiagnostics alloc] init];
    }
    
    return diagnostics;
}


#pragma mark - Tracing methods

- (void)addTraceRoute:(MHPacket*)packet
         withNextPeer:(NSString*)peer
{
    if ([self useTraceInfo])
    {
        NSMutableArray *traceInfo = [packet.info objectForKey:MH_DIAGNOSTICS_TRACE];
        
        if (traceInfo == nil)
        {
            traceInfo = [[NSMutableArray alloc] init];
            [packet.info setObject:traceInfo forKey:MH_DIAGNOSTICS_TRACE];
        }
    }
}

- (NSArray *)tracePacket:(MHPacket*)packet
{
    if ([self useTraceInfo])
    {
        NSMutableArray *traceInfo = [packet.info objectForKey:MH_DIAGNOSTICS_TRACE];
        
        return traceInfo;
    }
    
    return nil;
}

@end