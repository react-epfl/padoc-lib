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

@end

@implementation MH6ShotsScheduler

#pragma mark - Initialization
- (instancetype)initWithRoutingTable:(NSMutableDictionary*)routingTable
{
    self = [super init];
    if (self)
    {
        self.schedules = [[NSMutableDictionary alloc] init];
        self.routingTable = routingTable;
    }
    
    return self;
}

- (void)dealloc
{
    self.schedules = nil;
}

- (void)clear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.schedules removeAllObjects];
    });
}

- (void)setScheduleFromPacket:(MHPacket*)packet
{
    
}


- (BOOL)isOnRoute:(NSDictionary*)routes
{
    for (id routeKey in routes)
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


- (NSTimeInterval)getDelay:(MHPacket*)packet
{
    
}

-(NSArray*)getTargets:(MHLocation*)senderLoc
{
    NSMutableArray *targets = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 6; i++)
    {
        MHLocation *target = [[MHLocation alloc] init];
        target.x = senderLoc.x + sin((M_PI/6) + i*(M_PI/3)) * MHRANGE;
        target.y = senderLoc.y + cos((M_PI/6) + i*(M_PI/3)) * MHRANGE;
    }
    
    return targets;
}


-(void)updateRoutes:(NSMutableDictionary*)routes
{
    
}
@end