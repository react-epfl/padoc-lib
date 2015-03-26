//
//  MHConnectionBuffer.m
//  Multihop
//
//  Created by quarta on 26/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHConnectionBuffer.h"



@interface MHConnectionBuffer ()

// Public properties
@property (nonatomic, strong) NSString *peerID;
@property (nonatomic, readwrite) NSUInteger status;

@property (nonatomic, strong) NSMutableArray *messages;

@end

@implementation MHConnectionBuffer

#pragma mark - Life Cycle

- (instancetype)initWithPeerID:(NSString *)peerID
{
    self = [super init];
    if (self)
    {
        self.peerID = peerID;
        self.messages = [[NSMutableArray alloc] init];
        self.status = MHConnectionBufferDisconnected;
    }
    return self;
}

- (void)dealloc
{
    [self.messages removeAllObjects];
    self.messages = nil;
}


# pragma mark - Properties
- (void)setStatus:(NSUInteger)status
{
    self.status = status;
}


- (void)pushData:(NSData *)data
{
    [self.messages addObject:data];
}

- (NSData *)popData
{
    if (self.messages.count > 0)
    {
        return [self.messages objectAtIndex:0];
    }
    
    return nil;
}

@end