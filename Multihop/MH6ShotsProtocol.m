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
        self.routingTable = [[NSMutableDictionary alloc] init];
        [self.routingTable setObject:[NSNumber numberWithInt:0] forKey:[self getOwnPeer]];
        
        self.joinMsgs = [[NSMutableDictionary alloc] init];
        self.shouldForward = [[NSMutableDictionary alloc] init];
        
        self.scheduler = [[MH6ShotsScheduler alloc] initWithRoutingTable:self.routingTable];
        self.scheduler.delegate = self;
        
        [[MHLocationManager getSingleton] start];
        [self.cHandler connectToAll];
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
                                               withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [packet.info setObject:@"-[join-msg]-" forKey:@"message-type"];
    [packet.info setObject:groupName forKey:@"groupName"];
    [packet.info setObject:[NSNumber numberWithInt:0] forKey:@"height"];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.joinMsgs setObject:packet forKey:packet.tag];
        [self.shouldForward setObject:[[NSNumber alloc] initWithBool:YES] forKey:packet.tag];
        
        NSError *error;
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
    });
}

- (void)leaveGroup:(NSString *)groupName
{
    // TODO: ???
}




- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    if([packet.info objectForKey:@"routes"] == nil)
    {
        [packet.info setObject:[[NSMutableDictionary alloc] init] forKey:@"routes"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *routes = [packet.info objectForKey:@"routes"];
        for (id msgKey in self.joinMsgs)
        {
            MHPacket *msg = [self.joinMsgs objectForKey:msgKey];
            if([packet.destinations containsObject:[msg.info objectForKey:@"groupName"]])
            {
                if([self.routingTable objectForKey:msg.source] != nil)
                {
                    [routes setObject:[self.routingTable objectForKey:msg.source] forKey:msg.source];
                }
            }
        }
    
        NSError *error;
        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
    });
}




#pragma mark - ConnectionsHandler methods
- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
    [self.neighbourPeers addObject:peer];
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    [self.neighbourPeers removeObject:peer];
}


- (void)cHandler:(MHConnectionsHandler *)cHandler
  didReceiveData:(NSData *)data
        fromPeer:(NSString *)peer
{
    MHPacket *packet = [MHPacket fromNSData:data];
    
    NSString * msgType = [packet.info objectForKey:@"message-type"];
    if (msgType != nil && [msgType isEqualToString:@"-[join-msg]-"]) // it's a join message
    {
        if (![self.joinMsgs objectForKey:packet.tag])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.joinMsgs setObject:packet forKey:packet.tag];
                
                int height = [[packet.info objectForKey:@"height"] intValue] + 1;

                [self.routingTable setObject:[NSNumber numberWithInt:height] forKey:packet.source];
                [self.shouldForward setObject:[NSNumber numberWithBool:YES] forKey:packet.tag];
                
                
                // Dispatch after y seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(2) + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([[self.shouldForward objectForKey:packet.tag] boolValue])
                    {
                        NSError *error;
                        [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
                    }
                });
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.shouldForward setObject:[NSNumber numberWithBool:NO] forKey:packet.tag];
            });
        }
    }
    else
    {
        NSMutableDictionary *routes = [packet.info objectForKey:@"routes"];
        for (id routeKey in routes)
        {
            int g = [[routes objectForKey:routeKey] intValue];
            
            if(g == 0)
            {
                [routes removeObjectForKey:routeKey];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate mhProtocol:self didReceivePacket:packet];
                });
            }
        }

        [self.scheduler setScheduleFromPacket:packet];
    }
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
  enteredStandby:(NSString *)info
            peer:(NSString *)peer
{
    
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
   leavedStandby:(NSString *)info
            peer:(NSString *)peer
{
    
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


@end