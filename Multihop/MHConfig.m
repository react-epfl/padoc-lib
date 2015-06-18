//
//  MHParameters.m
//  Multihop
//
//  Created by quarta on 17/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//



#import "MHConfig.h"


@interface MHConfig ()


@end


#pragma mark - Singleton static variables

static MHConfig *params = nil;



@implementation MHConfig

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        [self setDefaults];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)setDefaults
{
    // Link layer
    self.linkHeartbeatSendDelay = 1;
    self.linkMaxHeartbeatFails = 5;
    
    self.linkDatagramSendDelay = 10;
    self.linkMaxDatagramSize = 5000;
    self.linkBackgroundDatagramSendDelay = 20;
    
    // Network layer
    self.netFloodingPacketTTL = 100;
    
    self.net6ShotsControlPacketForwardDelayRange = 50;
    self.net6ShotsControlPacketForwardDelayBase = 20;
    self.net6ShotsPacketForwardDelayRange = 100;
    self.net6ShotsPacketForwardDelayBase = 30;
    self.net6ShotsOverlayMaintenanceDelay = 5000;
}

#pragma mark - Singleton methods
+ (MHConfig*)getSingleton
{
    if (params == nil)
    {
        // Initialize the parameters singleton
        params = [[MHConfig alloc] init];
    }
    
    return params;
}

@end