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

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.source = [decoder decodeObjectForKey:@"source"];
        self.destinations = [decoder decodeObjectForKey:@"destinations"];
        self.data = [decoder decodeObjectForKey:@"data"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.source forKey:@"source"];
    [encoder encodeObject:self.destinations forKey:@"destinations"];
    [encoder encodeObject:self.data forKey:@"data"];
}


- (void)dealloc
{
    [self.pathInfo removeAllObjects];
    self.pathInfo = nil;
    
    self.destinations = nil;
}


- (NSData *)asNSData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    return data;
}


+ (MHPacket *)fromNSData:(NSData *)nsData
{
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:nsData];

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