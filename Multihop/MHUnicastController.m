//
//  MHUnicastController.m
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHUnicastController.h"


@interface MHUnicastController () <MHUnicastRoutingProtocolDelegate, MHUnicastConnectionDelegate>

@property (nonatomic, strong) MHUnicastRoutingProtocol *mhProtocol;
@property (nonatomic, strong) NSMutableDictionary *connections;
@end

@implementation MHUnicastController

#pragma mark - Life Cycle
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHUnicastProtocol)protocol
{
    self = [super init];
    if (self)
    {
        switch (protocol) {
            case MHUnicastFloodingProtocol:
                self.mhProtocol = [[MHFloodingProtocol alloc] initWithServiceType:serviceType
                                                                      displayName:displayName];
                break;
                
            default:
                self.mhProtocol = [[MHFloodingProtocol alloc] initWithServiceType:serviceType
                                                                      displayName:displayName];
                break;
        }
        
        self.mhProtocol.delegate = self;
        self.connections = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.mhProtocol  = nil;
    self.connections = nil;
}

#pragma mark - Membership

- (void)disconnect
{
    [self.mhProtocol disconnect];
    [self.connections removeAllObjects];
}


#pragma mark - Communicate

- (void)sendMessage:(MHMessage *)message
     toDestinations:(NSArray *)destinations
              error:(NSError **)error
{
    for (id dest in destinations)
    {
        MHUnicastConnection *connection = [self.connections objectForKey:dest];
        
        // Create a new reliable connection
        if (connection == nil)
        {
            connection = [[MHUnicastConnection alloc] initWithRoutingProtocol:self.mhProtocol
                                                                  withOwnPeer:[self getOwnPeer]
                                                               withTargetPeer:dest];
            
            // Initiate handshaking
            [connection handshake];
            
            [self.connections setObject:connection forKey:dest];
        }
        
        NSError *err;
        [connection sendMessage:message error:&err];
    }
}

- (NSString *)getOwnPeer
{
    return [self.mhProtocol getOwnPeer];
}

- (int)hopsCountFromPeer:(NSString*)peer
{
    return [self.mhProtocol hopsCountFromPeer:peer];
}



#pragma mark - Background Mode methods
- (void)applicationWillResignActive {
    [self.mhProtocol applicationWillResignActive];
}

- (void)applicationDidBecomeActive{
    [self.mhProtocol applicationDidBecomeActive];
}



# pragma mark - Termination method
- (void)applicationWillTerminate {
    [self disconnect];
}




#pragma mark - MHUnicastRoutingProtocol Delegates

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self isDiscovered:info peer:peer displayName:displayName];
    });
}

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   hasDisconnected:(NSString *)info
              peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self hasDisconnected:info peer:peer];
    });
}

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self failedToConnect:error];
    });
}

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
     withTraceInfo:(NSArray *)traceInfo
{
    MHUnicastConnection *connection = [self.connections objectForKey:packet.source];
    
    // Create a new reliable connection
    if (connection == nil)
    {
        connection = [[MHUnicastConnection alloc] initWithRoutingProtocol:self.mhProtocol
                                                              withOwnPeer:[self getOwnPeer]
                                                           withTargetPeer:packet.source];
        
        
        [self.connections setObject:connection forKey:packet.source];
    }

    // Unarchive message data
    id message = [NSKeyedUnarchiver unarchiveObjectWithData:packet.data];
    
    if ([message isKindOfClass:[MHMessage class]])
    {
        [connection messageReceived:message withTraceInfo:traceInfo];
    }
}


#pragma mark - MHUnicastConnection Delegates
- (void)mhUnicastConnection:(MHUnicastConnection *)mhUnicastConnection
             isDisconnected:(NSString *)info
                       peer:(NSString *)peer
{
    
}

- (void)mhUnicastConnection:(MHUnicastConnection *)mhUnicastConnection
          didReceiveMessage:(MHMessage *)message
                   fromPeer:(NSString *)peer
              withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self didReceiveMessage:message fromPeer:peer withTraceInfo:traceInfo];
    });
}
@end