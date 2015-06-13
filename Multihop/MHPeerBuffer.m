//
//  MHPeerBuffer.m
//  Multihop
//
//  Created by quarta on 13/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHPeerBuffer.h"



@interface MHPeerBuffer()

// Public properties

@property (nonatomic, strong) NSMutableArray *datagrams;
@property (nonatomic, strong) MCSession *session;

@property (nonatomic) BOOL connected;
@property (nonatomic) int releaseDelay;

@property (copy) void (^releaseDatagrams)(void);

@end

@implementation MHPeerBuffer

#pragma mark - Life Cycle

- (instancetype)initWithMCSession:(MCSession *)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.connected = NO;
        self.releaseDelay = MHPEERBUFFER_RELEASE_DELAY;

        self.datagrams = [[NSMutableArray alloc] init];

        
        
        MHPeerBuffer * __weak weakSelf = self;
        
        
        self.releaseDatagrams = ^{
            if (weakSelf)
            {
                MHDatagram * datagram = [weakSelf popDatagram];
                NSError *error;
                
                if (datagram != nil)
                {
                    if (weakSelf.connected)
                    {
                        [weakSelf.session sendData:[datagram asNSData]
                                       toPeers:weakSelf.session.connectedPeers
                                      withMode:MCSessionSendDataUnreliable
                                         error:&error];
                    }
                }
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakSelf.releaseDelay * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.releaseDatagrams);
            }
        };
        
        // Check every x seconds for buffered messages
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.releaseDelay * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.releaseDatagrams);
    }
    return self;
}

- (void)dealloc
{
    [self.datagrams removeAllObjects];
    self.datagrams = nil;
}

- (void)setConnected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connected = YES;
    });
}

- (void)setDisconnected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connected = NO;
    });
}

- (void)pushDatagram:(MHDatagram *)datagram
{
    // If buffer size is reached, messages are lost
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.datagrams.count < MHPEERBUFFER_BUFFER_SIZE)
        {
            [self.datagrams addObject:datagram];
        }
    });
}

- (MHDatagram *)popDatagram
{
    // Pop first item and return
    if (self.datagrams.count > 0)
    {
        MHDatagram *datagram = [self.datagrams objectAtIndex:0];
        [self.datagrams removeObjectAtIndex:0];
        
        return datagram;
    }
    
    return nil;
}

@end