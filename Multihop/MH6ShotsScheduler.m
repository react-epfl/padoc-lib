//
//  MH6ShotsScheduler.m
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MH6ShotsScheduler.h"



@interface MH6ShotsScheduler ()

@property (nonatomic, strong) NSMutableDictionary *routingTable;
@property (nonatomic, strong) NSMutableDictionary *neighbourRoutingTables;

@property (nonatomic, strong) NSString *localhost;

@property (copy) void (^processSchedule)(void);
@property (copy) void (^overlayMaintenance)(void);

@end

@implementation MH6ShotsScheduler

#pragma mark - Initialization
- (instancetype)initWithRoutingTable:(NSMutableDictionary*)routingTable
                       withLocalhost:(NSString*)localhost
{
    self = [super init];
    if (self)
    {
        self.schedules = [[NSMutableDictionary alloc] init];
        self.routingTable = routingTable;
        self.localhost = localhost;
        
        self.neighbourRoutingTables = [[NSMutableDictionary alloc] init];
        
        
        MH6ShotsScheduler * __weak weakSelf = self;
        

        self.processSchedule = ^{
            if (weakSelf)
            {
                NSDate* d = [NSDate date];
                NSInteger currTime = [d timeIntervalSince1970];
                
                NSArray *scheduleKeys = [weakSelf.schedules allKeys];
                
                for(id scheduleKey in scheduleKeys)
                {
                    MH6ShotsSchedule *schedule = [weakSelf.schedules objectForKey:scheduleKey];
                    
                    if(schedule.time != -1 && schedule.time <= currTime)
                    {
                        [weakSelf updateRoutes:[schedule.packet.info objectForKey:@"routes"] withWeakSelf:weakSelf];
                        [schedule.packet.info setObject:[[MHLocationManager getSingleton] getMPosition] forKey:@"senderLocation"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.delegate mhScheduler:weakSelf broadcastPacket:schedule.packet];
                        });
                        
                        schedule.time = -1;
                    }
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH6SHOTS_PROCESSSCHEDULE_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.processSchedule);
            }
        };
        
        
        self.overlayMaintenance = ^{
            if (weakSelf)
            {
                if (weakSelf.neighbourRoutingTables.count > 0)
                {
                    NSArray *rtKeys = [weakSelf.routingTable allKeys];
                    for(id rtKey in rtKeys)
                    {
                        NSNumber *g = [weakSelf.routingTable objectForKey:rtKey];
                        
                        if([g intValue] != 0)
                        {
                            int newG = -1;
                            
                            NSArray *nrtKeys = [weakSelf.neighbourRoutingTables allKeys];
                            for(id nrtKey in nrtKeys)
                            {
                                NSDictionary *nRoutingTable = [weakSelf.neighbourRoutingTables objectForKey:nrtKey];
                                
                                NSNumber *gp = [nRoutingTable objectForKey:rtKey];
                                
                                if(gp != nil && ([gp intValue] < newG || newG == -1))
                                {
                                    newG = [gp intValue];
                                }

                            }
                            
                            [weakSelf.routingTable setObject:[NSNumber numberWithInt:newG+1] forKey:rtKey];
                        }
                    }
                    [weakSelf.neighbourRoutingTables removeAllObjects];
                }
                
                MHPacket *packet = [[MHPacket alloc] initWithSource:weakSelf.localhost
                                                   withDestinations:[[NSArray alloc] init]
                                                           withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [packet.info setObject:@"-[routingtable-msg]-" forKey:@"message-type"];
                [packet.info setObject:weakSelf.routingTable forKey:@"routing-table"];
                
                [weakSelf.delegate mhScheduler:weakSelf broadcastPacket:packet];

                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH6SHOTS_OVERLAYMAINTENANCE_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.overlayMaintenance);
            }
        };

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH6SHOTS_PROCESSSCHEDULE_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.processSchedule);
        
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH6SHOTS_OVERLAYMAINTENANCE_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.overlayMaintenance);
    }
    
    return self;
}

- (void)dealloc
{
    self.schedules = nil;
    self.neighbourRoutingTables = nil;
}

- (void)clear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.schedules removeAllObjects];
        [self.neighbourRoutingTables removeAllObjects];
    });
}

- (void)setScheduleFromPacket:(MHPacket*)packet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isOnRoute:[packet.info objectForKey:@"routes"]])
        {
            MH6ShotsSchedule *schedule = [self.schedules objectForKey:packet.tag];
            
            if (schedule != nil)
            {
                schedule.time = -1;
            }
            else
            {
                NSDate* d = [NSDate date];
                NSInteger t = [d timeIntervalSince1970] + [self getDelay:packet];
                [self.schedules setObject:[[MH6ShotsSchedule alloc] initWithPacket:packet withTime:t]
                                   forKey:packet.tag];
            }
        }
    });
}


- (BOOL)isOnRoute:(NSDictionary*)routes
{
    NSArray *routeKeys = [routes allKeys];
    for (id routeKey in routeKeys)
    {
        int g = [[routes objectForKey:routeKey] intValue];
        
        NSNumber *gp = [self.routingTable objectForKey:routeKey];
        
        if(gp != nil && [gp intValue] < g)
        {
            return YES;
        }
    }
    
    return NO;
}


- (NSInteger)getDelay:(MHPacket*)packet
{
    MHLocation *myLoc = [[MHLocationManager getSingleton] getMPosition];
    double d = -1.0;
    
    NSArray *targets = [self getTargets:[packet.info objectForKey:@"senderLocation"]];
    
    for(id targetObj in targets)
    {
        MHLocation *target = (MHLocation*)targetObj;
        
        if([MHLocationManager getDistanceFromMLocation:myLoc toMLocation:target] < d || d == -1.0)
        {
            d = [MHLocationManager getDistanceFromMLocation:myLoc toMLocation:target];
        }
    }
    
    return [self calculateDelay:d];
}

- (NSInteger)calculateDelay:(double)dist
{
    return ((double)MH6SHOTS_TARGET_DELAY_RANGE/(double)MH6SHOTS_RANGE)*dist + (double)MH6SHOTS_TARGET_DELAY_BASE;
}

-(NSArray*)getTargets:(MHLocation*)senderLoc
{
    NSMutableArray *targets = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 6; i++)
    {
        MHLocation *target = [[MHLocation alloc] init];
        target.x = senderLoc.x + sin((M_PI/6) + i*(M_PI/3)) * MH6SHOTS_RANGE;
        target.y = senderLoc.y + cos((M_PI/6) + i*(M_PI/3)) * MH6SHOTS_RANGE;
    }
    
    return targets;
}


-(void)updateRoutes:(NSMutableDictionary*)routes withWeakSelf:(MH6ShotsScheduler * __weak)weakSelf
{
    NSArray *routeKeys = [routes allKeys];
    for (id routeKey in routeKeys)
    {
        int g = [[routes objectForKey:routeKey] intValue];
        
        NSNumber *gp = [weakSelf.routingTable objectForKey:routeKey];
        
        if(gp != nil && [gp intValue] < g)
        {
            [routes setObject:gp forKey:routeKey];
        }
    }
}


#pragma mark - Maintenance methods
- (void)addNeighbourRoutingTable:(NSMutableDictionary*)routingTable
                      withSource:(NSString*)source
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![source isEqualToString:self.localhost])
        {
            [self.neighbourRoutingTables setObject:routingTable forKey:source];
        }
    });
}

@end