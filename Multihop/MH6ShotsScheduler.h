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

#define MHRANGE 40.0

@interface MH6ShotsScheduler : NSObject

@property (nonatomic, readwrite) NSMutableDictionary *schedules;

#pragma mark - Initialization
- (instancetype)initWithRoutingTable:(NSMutableDictionary*)routingTable;

- (void)clear;


- (void)setScheduleFromPacket:(MHPacket*)packet;

@end

#endif
