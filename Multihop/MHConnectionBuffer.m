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
@property (nonatomic, readwrite) MHConnectionBufferState status;

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) MHMultipeerWrapper *mcWrapper;

@property (copy) void (^releaseMessages)(void);

@end

@implementation MHConnectionBuffer

#pragma mark - Life Cycle

- (instancetype)initWithPeerID:(NSString *)peerID
          withMultipeerWrapper:(MHMultipeerWrapper *)mcWrapper
{
    self = [super init];
    if (self)
    {
        self.mcWrapper = mcWrapper;
        self.peerID = peerID;
        self.messages = [[NSMutableArray alloc] init];
        [self setStatus:MHConnectionBufferConnected];
        
        
        MHConnectionBuffer * __weak weakSelf = self;
        
        
        self.releaseMessages = ^{
            if (weakSelf && weakSelf.messages)
            {
                if (weakSelf.status == MHConnectionBufferConnected)
                {
                    NSData * data = [weakSelf popData];
                    NSError *error;
                    
                    if (data != nil)
                    {
                        [weakSelf.mcWrapper sendData:data
                                             toPeers:[[NSArray alloc] initWithObjects:weakSelf.peerID, nil]
                                            reliable:YES
                                               error:&error];
                    }
                }
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.releaseMessages);
            }
        };
        
        // Check every 0.1 seconds for buffered messages
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.releaseMessages);
    }
    return self;
}

- (void)dealloc
{
    [self.messages removeAllObjects];
    self.messages = nil;
}


# pragma mark - Properties
- (void)setStatus:(MHConnectionBufferState)status
{
    _status = status;
}


- (void)pushData:(NSData *)data
{
    // If buffer size is reached, messages are lost
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.messages.count < MHCONNECTIONBUFFER_BUFFER_SIZE)
        {
            [self.messages addObject:data];
        }
    });
}

- (NSData *)popData
{
    if (self.messages.count > 0)
    {
        NSData *data = [self.messages objectAtIndex:0];
        [self.messages removeObject:data];
        
        return data;
    }
    
    return nil;
}

@end