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

@property (nonatomic, strong) NSMutableDictionary *chunks;

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

        self.chunks = [[NSMutableDictionary alloc] init];
        
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
    
    [self.chunks removeAllObjects];
    self.chunks = nil;
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
        // We have to divide datagrams into 500 bytes chunks
        // otherwise the receiving side is too slow
        int nbChunks = ceil(((double)datagram.data.length / MHPEERBUFFER_MAX_CHUNK_SIZE));
        NSString *tag = [MHComputation makeUniqueStringFromSource:[NSString stringWithFormat:@"%d", arc4random_uniform(1000)]];
        
        for (int i = 0; i < nbChunks; i++)
        {
            int length = MHPEERBUFFER_MAX_CHUNK_SIZE;
            
            if (i == nbChunks - 1) // Last chunk
            {
                length = datagram.data.length - (i * MHPEERBUFFER_MAX_CHUNK_SIZE);
            }
            
            MHDatagram *chunk = [[MHDatagram alloc] initWithData:[datagram.data subdataWithRange:NSMakeRange(i * MHPEERBUFFER_MAX_CHUNK_SIZE, length)]];
            chunk.tag = tag;
            chunk.noChunk = i;
            chunk.chunksNumber = nbChunks;
            
            
            if (self.datagrams.count < MHPEERBUFFER_BUFFER_SIZE)
            {
                [self.datagrams addObject:chunk];
            }
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


- (void)didReceiveDatagramChunk:(MHDatagram *)chunk
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *chunksList = [self.chunks objectForKey:chunk.tag];
        
        if (chunksList == nil)
        {
            chunksList = [[NSMutableArray alloc] init];
            [self.chunks setObject:chunksList forKey:chunk.tag];
        }
        
        // Potentially unordered
        [chunksList addObject:chunk];
        
        // Generate complete chunk
        if (chunksList.count == chunk.chunksNumber)
        {
            [chunksList sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
                
                MHDatagram *d1 = (MHDatagram*)obj1;
                MHDatagram *d2 = (MHDatagram*)obj2;
                if (d1.noChunk > d2.noChunk) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if (d1.noChunk < d2.noChunk) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSMutableData *completeData = [NSMutableData data];
            MHDatagram *finalDatagram = [[MHDatagram alloc] initWithData:completeData];
            
            for (int i = 0; i < chunksList.count; i++)
            {
                MHDatagram *partialChunk = (MHDatagram *)[chunksList objectAtIndex:i];
                [completeData appendData:partialChunk.data];
            }
            
            [self.chunks removeObjectForKey:chunk.tag];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhPeerBuffer:self didReceiveDatagram:finalDatagram];
            });
        }
    });
}

@end