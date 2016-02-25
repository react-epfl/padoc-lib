/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
        self.status = MHConnectionBufferConnected;
        
        
        MHConnectionBuffer * __weak weakSelf = self;
        
        
        self.releaseMessages = ^{
            if (weakSelf)
            {
                // If connection is reestablished, then send data
                if (weakSelf.status == MHConnectionBufferConnected)
                {
                    MHDatagram * datagram = [weakSelf popDatagram];
                    NSError *error;
                    
                    if (datagram != nil)
                    {
                        [weakSelf.mcWrapper sendDatagram:datagram
                                                 toPeers:[[NSArray alloc] initWithObjects:weakSelf.peerID, nil]
                                                   error:&error];
                    }
                }
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([MHConfig getSingleton].linkBackgroundDatagramSendDelay * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.releaseMessages);
            }
        };
        
        // Check every x seconds for buffered messages
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([MHConfig getSingleton].linkBackgroundDatagramSendDelay * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.releaseMessages);
    }
    return self;
}

- (void)dealloc
{
    [self.messages removeAllObjects];
    self.messages = nil;
    
    self.peerID = nil;
    self.mcWrapper = nil;
}


# pragma mark - Properties
- (void)setConnectionStatus:(MHConnectionBufferState)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.status = status;
    });
}


- (void)pushDatagram:(MHDatagram *)datagram
{
    // If buffer size is reached, messages are lost
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.messages.count < MHCONNECTIONBUFFER_BUFFER_SIZE)
        {
            [self.messages addObject:datagram];
        }
    });
}

- (MHDatagram *)popDatagram
{
    // Pop first item and return
    if (self.messages.count > 0)
    {
        MHDatagram *datagram = [self.messages objectAtIndex:0];
        [self.messages removeObjectAtIndex:0];
        
        return datagram;
    }
    
    return nil;
}

@end