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
        MHConnectionsHandler * __weak weakSelf = self;
        
        self.backgroundTaskEndHandler = ^{
            [weakSelf sendBackgroundSignal:weakSelf];
            
            
            //This is called 3 seconds before the time expires
            UIBackgroundTaskIdentifier newTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:weakSelf.backgroundTaskEndHandler];
            
            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTask];
            
            // A new background task is created
            weakSelf.backgroundTask = newTask;
        };
    }
    return self;
}

- (void)sendBackgroundSignal:(MHConnectionsHandler * __weak)weakSelf
{
    // Send signal
    NSError *error;
    [weakSelf.mcWrapper sendData:[MHCONNECTIONSHANDLER_BACKGROUND_SIGNAL dataUsingEncoding:NSUTF8StringEncoding]
                         toPeers:[weakSelf.buffers allKeys]
                        reliable:YES
                           error:&error];
    
    // Set to Broken the connection status of all peers
    for (id peerKey in weakSelf.buffers)
    {
        MHConnectionBuffer *buf = [self.buffers objectForKey:peerKey];
        
        [buf setStatus:MHConnectionBufferBroken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self enteredStandby:@"Standby" peer:peerKey];
        });
    }
}

- (void)dealloc
{
    self.mcWrapper  = nil;
    self.buffers = nil;
}

#pragma mark - Membership

- (void)connectToNeighbourhood
{
    [self.mcWrapper connectToNeighbourhood];
}


- (void)disconnectFromNeighbourhood
{
    [self.buffers removeAllObjects];
    [self.mcWrapper disconnectFromNeighbourhood];
}

#pragma mark - Communicate
- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
           error:(NSError **)error
{
    NSMutableArray *connectedPeers = [[NSMutableArray alloc] init];
    
    
    for (id peerObj in peers)
    {
        NSString *peer = (NSString*)peerObj;
        MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
        
        // For each peer, if its connection is Broken, we bufferize instead
        // of sending
        if(buf != nil)
        {
            if (buf.status == MHConnectionBufferBroken) // We bufferize
            {
                // Data bufferization
                [buf pushData:data];
            }
            else
            {
                [connectedPeers addObject:peerObj];
            }
        }
    }
    
    // The connectedPeers array contains only peers
    // with an unbroken connection
    if (connectedPeers.count > 0)
    {
        [self.mcWrapper sendData:data
                         toPeers:connectedPeers
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
    // Start background tasks
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:self.backgroundTaskEndHandler];
}


- (void)applicationDidBecomeActive
{
    // Stop background tasks
    self.backgroundTask = UIBackgroundTaskInvalid;
}




#pragma mark - MHMultipeerWrapper Delegates

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName
{
    MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
    
    // A peer connects for the first time, we notify the above layers
    if (buf == nil)
    {
        buf = [[MHConnectionBuffer alloc] initWithPeerID:peer
                                    withMultipeerWrapper:self.mcWrapper];
        
        // Unbroken connection
        [buf setStatus:MHConnectionBufferConnected];
        
        [self.buffers setObject:buf forKey:peer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self hasConnected:info peer:peer displayName:displayName];
        });
    }
    else // The peer has reconnected, we do not notify the above layers yet
    {
        [buf setStatus:MHConnectionBufferConnected];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self leavedStandby:@"Active" peer:peer];
        });
    }
}



- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer
{
    MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
    

    if (buf.status == MHConnectionBufferConnected)
    {
        // The peer has disconnected for a cause other than background mode,
        // thus remove from list
        [self.buffers removeObjectForKey:peer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self hasDisconnected:info peer:peer];
        });
    }
    else if(buf.status == MHConnectionBufferBroken)
    {
        // The peer has disconnected because of the expiration of
        // the background task, thus bufferize messages
        MHConnectionsHandler * __weak weakSelf = self;
        
        // Check after some seconds whether the peer has reconnected, otherwise notify the above layers
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MHCONNECTIONSHANDLER_CHECK_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf && weakSelf.buffers)
            {
                MHConnectionBuffer *buf = [weakSelf.buffers objectForKey:peer];
                
                if(buf != nil && buf.status == MHConnectionBufferBroken)
                {
                    // Still disconnected, then we remove it and notify upper layers
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
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Check if it is a background signal
    if ([dataStr isEqualToString:MHCONNECTIONSHANDLER_BACKGROUND_SIGNAL])
    {
        // Set peer status to Broken
        MHConnectionBuffer *buf = [self.buffers objectForKey:peer];
        
        [buf setStatus:MHConnectionBufferBroken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self enteredStandby:@"Standby" peer:peer];
        });
    }
    else
    {
        // Notify above layers
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cHandler:self didReceiveData:data fromPeer:peer];
        });
    }
}

@end