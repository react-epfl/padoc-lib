//
//  MHPacket.m
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHPacket.h"



@interface MHPacket ()

@property (nonatomic, readwrite, strong) NSString *source;
@property (nonatomic, readwrite, strong) NSArray *destinations;
@property (nonatomic, readwrite, strong) NSData *data;

@property (nonatomic, readwrite, strong) NSMutableDictionary *pathInfo;

@end

@implementation MHPacket

- (instancetype)initWithSource:(NSString *)source
               withDestinations:(NSArray *)destinations
                      withData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        self.source = source;
        self.destinations = destinations;
        self.data = data;
        
        self.pathInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [self.pathInfo removeAllObjects];
    self.pathInfo = nil;
    
    self.destinations = nil;
}


- (NSData *)asNSData
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:0 error:&error];
    
    if(error)
    {
        return nil;
    }
    
    return data;
}


+ (MHPacket *)fromNSData:(NSData *)nsData
{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:nsData
                                                options:0
                                                  error:&error];
    
    if(error)
    {
        return nil;
    }
    

    if([object isKindOfClass:[MHPacket class]])
    {
        MHPacket *packet = object;
        
        return packet;
    }
    else
    {
        return nil;
    }
}

@end