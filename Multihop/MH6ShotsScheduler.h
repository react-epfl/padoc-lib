//
//  MH6ShotsScheduler.h
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MH6ShotsScheduler_h
#define Multihop_MH6ShotsScheduler_h

#import <Foundation/Foundation.h>
#import "MHLocationManager.h"
#import "MH6ShotsSchedule.h"
#import "MHPacket.h"

#define MH6SHOTS_RANGE 40.0
#define MH6SHOTS_PROCESSSCHEDULE_DELAY 500
#define MH6SHOTS_OVERLAYMAINTENANCE_DELAY 500

@protocol MH6ShotsSchedulerDelegate;

@interface MH6ShotsScheduler : NSObject

@property (nonatomic, weak) id<MH6ShotsSchedulerDelegate> delegate;

@property (nonatomic, readwrite) NSMutableDictionary *schedules;

#pragma mark - Initialization
- (instancetype)initWithRoutingTable:(NSMutableDictionary*)routingTable
                       withLocalhost:(NSString*)localhost;

- (void)clear;


- (void)setScheduleFromPacket:(MHPacket*)packet;

- (void)addNeighbourRoutingTable:(NSMutableDictionary*)routingTable
                      withSource:(NSString*)source;

@end

/**
 The delegate for the MH6ShotsScheduler class.
 */
@protocol MH6ShotsSchedulerDelegate <NSObject>

@required
- (void)mhScheduler:(MH6ShotsScheduler *)mhScheduler
    broadcastPacket:(MHPacket*)packet;

@end

#endif
