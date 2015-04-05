//
//  MH6ShotsSchedule.m
//  Multihop
//
//  Created by quarta on 04/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MH6ShotsSchedule.h"


@interface MH6ShotsSchedule ()

@property (nonatomic, readwrite) MHPacket *packet;


@end

@implementation MH6ShotsSchedule

#pragma mark - Initialization
- (instancetype)initWithPacket:(MHPacket *)packet
                      withTime:(NSInteger)time
{
    self = [super init];
    if (self)
    {
        self.packet = packet;
        self.time = time;
    }
    
    return self;
}

- (void)dealloc
{
    self.packet = nil;
}

@end