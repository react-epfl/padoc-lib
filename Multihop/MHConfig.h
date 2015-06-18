//
//  MHParameters.h
//  Multihop
//
//  Created by quarta on 17/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHParameters_h
#define Multihop_MHParameters_h

#import <Foundation/Foundation.h>

#define MHPEER_HEARTBEAT_TIME 1
#define MHPEER_MAX_HEARTBEAT_FAILS 5



#define MHPEERBUFFER_RELEASE_DELAY 10
#define MHPEERBUFFER_MAX_CHUNK_SIZE 5000

#define MHCONNECTIONBUFFER_RELEASE_TIME 20



#define MH_FLOODING_TTL 100



#define MH6SHOTS_JOINFORWARD_DELAY_RANGE 50
#define MH6SHOTS_JOINFORWARD_DELAY_BASE 20

#define MH6SHOTS_OVERLAYMAINTENANCE_DELAY 5000

#define MH6SHOTS_TARGET_DELAY_BASE 30
#define MH6SHOTS_TARGET_DELAY_RANGE 100


@interface MHConfig : NSObject

#pragma mark - Link layer
@property (nonatomic, readwrite) int linkHeartbeatSendDelay; // in seconds (default 1)
@property (nonatomic, readwrite) int linkMaxHeartbeatFails; // default 5

@property (nonatomic, readwrite) int linkDatagramSendDelay; // in ms (default 10)
@property (nonatomic, readwrite) int linkMaxDatagramSize; // default 5000
@property (nonatomic, readwrite) int linkBackgroundDatagramSendDelay; // in ms (default 20)

#pragma mark - Network layer
@property (nonatomic, readwrite) int netFloodingPacketTTL; // default 100

@property (nonatomic, readwrite) int net6ShotsControlPacketForwardDelayRange; // in ms (default 50)
@property (nonatomic, readwrite) int net6ShotsControlPacketForwardDelayBase; // in ms (default 20)
@property (nonatomic, readwrite) int net6ShotsPacketForwardDelayRange; // in ms (default 100)
@property (nonatomic, readwrite) int net6ShotsPacketForwardDelayBase; // in ms (default 30)
@property (nonatomic, readwrite) int net6ShotsOverlayMaintenanceDelay; // in ms (default 5000)



- (instancetype)init;

+ (MHConfig*)getSingleton;

- (void)setDefaults;


@end

#endif
