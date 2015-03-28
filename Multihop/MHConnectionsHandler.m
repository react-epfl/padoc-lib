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

@property (nonatomic, strong) NSString *BackgroundSignal;


@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (copy) void (^backgroundTaskEndHandler)(void);


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

        
        
        // Background task end handler
        self.BackgroundSignal = @"[{_-background-_}]";
        MHConnectionsHandler * __weak weakSelf = self;
        
        self.backgroundTaskEndHandler = ^{
            [weakSelf sendBackgroundSignal:weakSelf];
            
            
            //This is called 3 seconds before the time expires
            UIBackgroundTaskIdentifier newTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:weakSelf.backgroundTaskEndHandler];
            
            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTask];
            
            weakSelf.backgroundTask = newTask;
        };
    }
    return self;
}

- (void)sendBackgroundSignal:(MHConnectionsHandler * __weak)weakSelf
{
    NSError *error;
    [weakSelf.mcWrapper sendData:[weakSelf.BackgroundSignal dataUsingEncoding:NSUTF8StringEncoding]
                         toPeers:[weakSelf.buffers allKeys]
                        reliable:YES
                           error:&error];
    
    for (id peerKey in weakSelf.buffers)
    {
        MHConnectionBuffer *buf = [self.buffers objectForKey:peerKey];
        
        [buf setStatus:MHConnectionBufferBroken];
    }
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



#pragma mark - Background handling

- (void)applicationWillResignActive
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:self.backgroundTaskEndHandler];
}


- (void)applicationDidBecomeActive
{
    self.backgroundTask = UIBackgroundTaskInvalid;
}




#pragma mark - MHMultipeerWrapper Delegates

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
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer
{
    NSLog(@"Peer disconnected");
    MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
    

    if (buf.status == MHConnectionBufferConnected)
    {
        [self.buffers removeObjectForKey:peer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self hasDisconnected:info peer:peer];
        });
    }
    else if(buf.status == MHConnectionBufferBroken) // The background task has expirated
    {
        MHConnectionsHandler * __weak weakSelf = self;
        // Check after 60 seconds whether the peer has reconnected, otherwise notify the above layers
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf && weakSelf.buffers)
            {
                MHConnectionBuffer *buf = [weakSelf.buffers objectForKey:peer];
                
                if(buf != nil && buf.status == MHConnectionBufferBroken) // Still deconnected, then we remove it and notify
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
    // TODO: find a faster way to check if it is the background signal
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([dataStr isEqualToString:self.BackgroundSignal])
    {
        MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
        
        [buf setStatus:MHConnectionBufferBroken];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(cHandler:didReceiveData:fromPeer:)])
            {
                [self.delegate cHandler:self didReceiveData:data fromPeer:peer];
            }
        });
    }
}

@end