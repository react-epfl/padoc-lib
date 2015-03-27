//
//  MHConnectionsHandler.m
//  consoleViewer
//
//  Created by quarta on 25/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHConnectionsHandler.h"


@interface MHConnectionsHandler () <MHMultipeerWrapperDelegate>

@property (nonatomic, strong) MHMultipeerWrapper *mcWrapper;
@property (nonatomic, strong) NSMutableDictionary *buffers;

@end

@implementation MHConnectionsHandler

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.mcWrapper = [[MHMultipeerWrapper alloc] initWithServiceType:serviceType
                                                             displayName:displayName];
        self.mcWrapper.delegate = self;
        
        self.buffers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.mcWrapper  = nil;
    [self.buffers removeAllObjects];
    
    self.buffers = nil;
}

#pragma mark - Membership

- (void)connectToAll
{
    [self.mcWrapper connectToAll];
}


- (void)disconnectFromAll
{
    [self.mcWrapper disconnectFromAll];
}

#pragma mark - Communicate
- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
           error:(NSError **)error
{
    NSMutableArray *bufferedPeers = [[NSMutableArray alloc] initWithArray:peers copyItems:YES];
    
    for (id peerObj in bufferedPeers)
    {
        NSString *peer = (NSString*)peerObj;
        MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
        
        if (buf.status == MHConnectionBufferBroken) // We bufferize
        {
            [bufferedPeers removeObject:peerObj];
            [buf pushData:data];
        }
    }
    
    if (bufferedPeers.count > 0)
    {
        [self.mcWrapper sendData:data
                         toPeers:bufferedPeers
                        reliable:YES
                           error:error];
    }
}

- (NSString *)getOwnPeer
{
    return [self.mcWrapper getOwnPeer];
}



#pragma mark - MHMultipeerWrapper Delegates
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer
{
    NSLog(@"Peer disconnected");
    MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
    
    // We define it as a broken connection instead of a disconnected one,
    // which means we do not immediately notify the above layers of the
    // disconnection, because the peer could reconnect very soon
    if (buf.status == MHConnectionBufferConnected)
    {
        [buf setStatus:MHConnectionBufferBroken];
        
        MHConnectionsHandler * __weak weakSelf = self;
        // Check after 10 seconds whether the peer has reconnected, otherwise notify the above layers
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf && weakSelf.buffers)
            {
                MHConnectionBuffer *buf = [weakSelf.buffers objectForKey:peer];
                
                if(buf.status == MHConnectionBufferBroken) // Still deconnected, then we remove it and notify
                {
                    [weakSelf.buffers removeObjectForKey:peer];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate cHandler:self hasDisconnected:info peer:peer];
                    });
                }
            }
        });
    }
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName
{
    NSLog(@"Peer connected");
    MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
    
    // A peer connects for the first time, we notify the above layers
    if (buf == nil)
    {
        buf = [[MHConnectionBuffer alloc] initWithPeerID:peer
               withMultipeerWrapper:self.mcWrapper];
        
        [buf setStatus:MHConnectionBufferConnected];
        
        [self.buffers setObject:buf forKey:peer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self hasConnected:info peer:peer displayName:displayName];
        });
    }
    else // The peer has reconnected, we do not notify the above layers yet
    {
        [buf setStatus:MHConnectionBufferConnected];
    }
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate cHandler:self failedToConnect:error];
    });
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
   didReceiveData:(NSData *)data
         fromPeer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(cHandler:didReceiveData:fromPeer:)])
        {
            [self.delegate cHandler:self didReceiveData:data fromPeer:peer];
        }
    });
}

@end