//
//  MHUnicastController.m
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHUnicastController.h"


@interface MHUnicastController () <MHUnicastRoutingProtocolDelegate, MHSUATPConnectionDelegate>

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
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id dest in destinations)
        {
            MHSUATPConnection *connection = [self.connections objectForKey:dest];
            
            // Create a new reliable connection
            if (connection == nil)
            {
                connection = [[MHSUATPConnection alloc] initWithTargetPeer:dest];
                connection.delegate = self;
                
                // Initiate handshaking
                [connection handshake];
                
                [self.connections setObject:connection forKey:dest];
            }
            
            [connection sendMessage:message];
        }
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        MHSUATPConnection *connection = [self.connections objectForKey:packet.source];
        
        // Create a new reliable connection
        if (connection == nil)
        {
            connection = [[MHSUATPConnection alloc] initWithTargetPeer:packet.source];
            connection.delegate = self;
            
            [self.connections setObject:connection forKey:packet.source];
        }
        
        // Unarchive message data
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:packet.data];
        
        if ([message isKindOfClass:[MHMessage class]])
        {
            // Inform transport protocol of the incoming message
            [connection messageReceived:message withTraceInfo:traceInfo];
        }
    });
}


#pragma mark - Diagnostics info callbacks
- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
     forwardPacket:(NSString *)info
        fromSource:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self forwardPacket:info fromSource:peer];
    });
}



#pragma mark - MHSUATPConnection Delegates
- (void)MHSUATPConnection:(MHSUATPConnection *)MHSUATPConnection
             isDisconnected:(NSString *)info
                       peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.connections removeObjectForKey:peer];
    });
}

- (void)MHSUATPConnection:(MHSUATPConnection *)MHSUATPConnection
          didReceiveMessage:(MHMessage *)message
                   fromPeer:(NSString *)peer
              withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self didReceiveMessage:message fromPeer:peer withTraceInfo:traceInfo];
    });
}

- (void)MHSUATPConnection:(MHSUATPConnection *)MHSUATPConnection
                         sendMessage:(MHMessage *)message
                              toPeer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        
        MHPacket *packet = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                           withDestinations:[[NSArray alloc] initWithObjects:peer, nil]
                                                   withData:[NSKeyedArchiver archivedDataWithRootObject:message]];
        
        [self.mhProtocol sendPacket:packet error:&error];
    });
}


@end