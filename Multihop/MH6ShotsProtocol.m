//
//  MH6ShotsProtocol.m
//  Multihop
//
//  Created by quarta on 04/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MH6ShotsProtocol.h"


@interface MH6ShotsProtocol () <MH6ShotsSchedulerDelegate>

@property (nonatomic, strong) NSMutableArray *neighbourPeers;
@property (nonatomic, strong) MHConnectionsHandler *cHandler;

@property (nonatomic, strong) NSMutableDictionary *joinMsgs;
@property (nonatomic, strong) NSMutableDictionary *shouldForward;
@property (nonatomic, strong) NSMutableDictionary *routingTable;
@property (nonatomic, strong) MH6ShotsScheduler *scheduler;


@end

@implementation MH6ShotsProtocol

#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super initWithServiceType:serviceType displayName:displayName];
    if (self)
    {
        // Routing table initialization with own peer having 0 hops
        self.routingTable = [[NSMutableDictionary alloc] init];
        [self.routingTable setObject:[NSNumber numberWithInt:0] forKey:[self getOwnPeer]];
        
        self.joinMsgs = [[NSMutableDictionary alloc] init];
        self.shouldForward = [[NSMutableDictionary alloc] init];
        
        self.scheduler = [[MH6ShotsScheduler alloc] initWithRoutingTable:self.routingTable
                          withLocalhost:[self getOwnPeer]];
        self.scheduler.delegate = self;
        
        [MHLocationManager setBeaconIDWithPeerID:[self getOwnPeer]];
        [[MHLocationManager getSingleton] start];
        [self.cHandler connectToNeighbourhood];
    }
    return self;
}

- (void)dealloc
{
    self.joinMsgs = nil;
    self.shouldForward = nil;
    self.routingTable = nil;
    self.scheduler = nil;
}


- (void)disconnect
{
    [self.joinMsgs removeAllObjects];
    [self.shouldForward removeAllObjects];
    [self.routingTable removeAllObjects];
    [self.scheduler clear];
    
    [[MHLocationManager getSingleton] stop];
    
    [super disconnect];
}



- (void)joinGroup:(NSString *)groupName
{
    MHPacket *packet = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                       withDestinations:[[NSArray alloc] init]
                                               withData:[MHComputation emptyData]];
    
    // Add group infomation
    [packet.info setObject:MH6SHOTS_JOIN_MSG forKey:@"message-type"];
    [packet.info setObject:groupName forKey:@"groupName"];
    [packet.info setObject:[NSNumber numberWithInt:0] forKey:@"height"];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *tag = [MH6ShotsProtocol joinIDFromPacket:packet];
        [self.joinMsgs setObject:packet forKey:tag];
        [self.shouldForward setObject:[[NSNumber alloc] initWithBool:YES] forKey:tag];
        
        // Broadcast joining request
        NSError *error;
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
    });
}

- (void)leaveGroup:(NSString *)groupName
{
    MHPacket *packet = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                       withDestinations:[[NSArray alloc] init]
                                               withData:[MHComputation emptyData]];
    
    // Add group infomation
    [packet.info setObject:MH6SHOTS_LEAVE_MSG forKey:@"message-type"];
    [packet.info setObject:groupName forKey:@"groupName"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Remove joinMsg from list
        NSString *tag = [MH6ShotsProtocol joinIDFromPacket:packet];
        [self.shouldForward removeObjectForKey:tag];
        [self.joinMsgs removeObjectForKey:tag];
        
        // Broadcast leave msg
        NSError *error;
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
    });
}




- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    // Diagnostics: trace
    [[MHDiagnostics getSingleton] addTraceRoute:packet withNextPeer:[self getOwnPeer]];
    
    if([packet.info objectForKey:@"routes"] == nil)
    {
        [packet.info setObject:[[NSMutableDictionary alloc] init] forKey:@"routes"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *routes = [packet.info objectForKey:@"routes"];
        
        NSArray *msgKeys = [self.joinMsgs allKeys];
        for (id msgKey in msgKeys)
        {
            // For each joinMsg, check if the group is contained in the packet destinations
            MHPacket *msg = [self.joinMsgs objectForKey:msgKey];
            if([packet.destinations containsObject:[msg.info objectForKey:@"groupName"]])
            {
                // If we have the destination peers in our routing table,
                // add the new route to the packet routes
                if([self.routingTable objectForKey:msg.source] != nil)
                {
                    [routes setObject:[self.routingTable objectForKey:msg.source] forKey:msg.source];
                }
            }
        }
    
        // Also insert peer location and id
        [packet.info setObject:[[MHLocationManager getSingleton] getMPosition] forKey:@"senderLocation"];
        [packet.info setObject:[self getOwnPeer] forKey:@"senderID"];
        
        // Broadcast packet
        NSError *error;
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
    });
}


- (int)hopsCountFromPeer:(NSString*)peer
{
    NSNumber *g =[self.routingTable objectForKey:peer];
    
    if (g != nil)
    {
        return [g intValue];
    }
    
    return 1000;
}


#pragma mark - ConnectionsHandler methods
- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Register iBeacon region for the new neighbour peer
        [[MHLocationManager getSingleton] registerBeaconRegionWithUUID:peer];
        [self.neighbourPeers addObject:peer];
        
        // Add new route toward him having 1 hop
        [self.routingTable setObject:[NSNumber numberWithInt:1] forKey:peer];
        
        // Send all our joinMsg
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *msgKeys = [self.joinMsgs allKeys];
            for (id msgKey in msgKeys)
            {
                MHPacket *msg = [self.joinMsgs objectForKey:msgKey];
                
                NSError *error;
                [self.cHandler sendData:[msg asNSData]
                                toPeers:[[NSArray alloc] initWithObjects:peer, nil]
                                  error:&error];
            }
        });
    });
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Unregister the peer iBeacon region
        [[MHLocationManager getSingleton] unregisterBeaconRegionWithUUID:peer];
        [self.neighbourPeers removeObject:peer];
        // Remove it from the routing table
        [self.routingTable removeObjectForKey:peer];
    });
}


- (void)cHandler:(MHConnectionsHandler *)cHandler
  didReceiveData:(NSData *)data
        fromPeer:(NSString *)peer
{
    MHPacket *packet = [MHPacket fromNSData:data];
    

    
    // Check what type of message it is
    NSString * msgType = [packet.info objectForKey:@"message-type"];
    if (msgType != nil && [msgType isEqualToString:MH6SHOTS_JOIN_MSG]) // it's a join message
    {
        [self processJoinPacket:packet];
    }
    else if (msgType != nil && [msgType isEqualToString:MH6SHOTS_LEAVE_MSG]) // it's a leave message
    {
        [self processLeavePacket:packet];
    }
    else if(msgType != nil && [msgType isEqualToString:MH6SHOTS_RT_MSG]) // it's a neighbour routing table message
    {
        [self processRTPacket:packet];
    }
    else // A normal packet
    {
        [self processNormalPacket:packet];
    }
}


- (void)processJoinPacket:(MHPacket *)packet
{
    // If the packet came from the own peer, we discard it
    if ([packet.source isEqualToString:[self getOwnPeer]])
    {
        return;
    }
    
    NSString *tag = [MH6ShotsProtocol joinIDFromPacket:packet];
    if (![self.joinMsgs objectForKey:tag])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.joinMsgs setObject:packet forKey:tag];
            
            // Increment the height and update packet
            int height = [[packet.info objectForKey:@"height"] intValue] + 1;
            [packet.info setObject:[NSNumber numberWithInt:height] forKey:@"height"];
            
            // Add joinMsg peer in routing table
            [self.routingTable setObject:[NSNumber numberWithInt:height] forKey:packet.source];
            [self.shouldForward setObject:[NSNumber numberWithBool:YES] forKey:tag];
            
            // Notify upper layers
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self
                              joinedGroup:@"Joined group"
                                     peer:packet.source
                                    group:[packet.info objectForKey:@"groupName"]];
            });
                           
            // Dispatch after y seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(MH6SHOTS_JOINFORWARD_DELAY_RANGE) + MH6SHOTS_JOINFORWARD_DELAY_BASE) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                // If we can still forward, we do it
                if ([[self.shouldForward objectForKey:tag] boolValue])
                {
                    NSError *error;
                    [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
                }
            });
        });
    }
    else
    {
        // We already received the same joinMsg, thus we do not forward it
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.shouldForward setObject:[NSNumber numberWithBool:NO] forKey:tag];
        });
    }
}

- (void)processLeavePacket:(MHPacket *)packet
{
    // If the packet came from the own peer, we discard it
    if ([packet.source isEqualToString:[self getOwnPeer]])
    {
        return;
    }
    
    NSString *tag = [MH6ShotsProtocol joinIDFromPacket:packet];
    
    // Check if the joinMsg exist in the list
    if ([self.joinMsgs objectForKey:tag])
    {
        // The group does exist and we haven't received yet any
        // other leave message
        dispatch_async(dispatch_get_main_queue(), ^{
            // Remove from joinMsg list
            [self.joinMsgs removeObjectForKey:tag];
            [self.shouldForward removeObjectForKey:tag];
            
            // Dispatch after y seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(MH6SHOTS_JOINFORWARD_DELAY_RANGE) + MH6SHOTS_JOINFORWARD_DELAY_BASE) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                // Broadcast to neighbourhood
                NSError *error;
                [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
            });
        });
    }
}

- (void)processRTPacket:(MHPacket *)packet
{
    // If the packet came from the own peer, we discard it
    if ([packet.source isEqualToString:[self getOwnPeer]])
    {
        return;
    }
    
    // Add neighbour routing table
    NSMutableDictionary *someRT = [packet.info objectForKey:@"routing-table"];
    
    [self.scheduler addNeighbourRoutingTable:someRT
                                  withSource:packet.source];
}

- (void)processNormalPacket:(MHPacket *)packet
{
    // Diagnostics: trace
    [[MHDiagnostics getSingleton] addTraceRoute:packet withNextPeer:[self getOwnPeer]];
    
    // Diagnostics: retransmission
    [[MHDiagnostics getSingleton] increaseReceivedPackets];
    
    // If the packet came from the own peer, we discard it
    if ([packet.source isEqualToString:[self getOwnPeer]])
    {
        return;
    }
    
    NSMutableDictionary *routes = [packet.info objectForKey:@"routes"];
    NSArray *routeKeys = [routes allKeys];
    for (id routeKey in routeKeys)
    {
        // Check if one of the packet destinations
        // is the current peer
        if ([routeKey isEqualToString:[self getOwnPeer]])
        {
            // Remove route because packet is delivered
            [routes removeObjectForKey:routeKey];
            
            // Notify upper layers
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhProtocol:self didReceivePacket:packet withTraceInfo:[[MHDiagnostics getSingleton] tracePacket:packet]];
            });
        }
    }
    
    // Set for scheduling
    [self.scheduler setScheduleFromPacket:packet];
}




- (void)cHandler:(MHConnectionsHandler *)cHandler
  enteredStandby:(NSString *)info
            peer:(NSString *)peer
{
    // We do not care about
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
   leavedStandby:(NSString *)info
            peer:(NSString *)peer
{
    // We do not care about
}

#pragma mark - MH6ShotsSchedulerDelegate methods
- (void)mhScheduler:(MH6ShotsScheduler *)mhScheduler
    broadcastPacket:(MHPacket*)packet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
    });
}


#pragma mark - Helper methods
+ (NSString *)joinIDFromPacket:(MHPacket *)packet
{
    return [NSString stringWithFormat:@"%@-%@", packet.source, [packet.info objectForKey:@"groupName"]];
}

@end