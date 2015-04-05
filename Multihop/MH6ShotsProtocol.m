//
//  MH6ShotsProtocol.m
//  Multihop
//
//  Created by quarta on 04/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MH6ShotsProtocol.h"


@interface MH6ShotsProtocol ()

@property (nonatomic, strong) NSMutableArray *neighbourPeers;
@property (nonatomic, strong) MHConnectionsHandler *cHandler;


@property (nonatomic, strong) NSMutableArray *joinedGroups;
@property (nonatomic, strong) NSMutableDictionary *joinMsgs;
@property (nonatomic, strong) NSMutableDictionary *shouldForward;
@property (nonatomic, strong) NSMutableDictionary *routingTable;

@end

@implementation MH6ShotsProtocol

#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super initWithServiceType:serviceType displayName:displayName];
    if (self)
    {
        self.joinedGroups = [[NSMutableArray alloc] init];

        
        self.routingTable = [[NSMutableDictionary alloc] init];
        [self.routingTable setObject:[[NSNumber alloc] initWithInt:0] forKey:[self getOwnPeer]];
        
        self.joinMsgs = [[NSMutableDictionary alloc] init];
        self.shouldForward = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.joinMsgs = nil;
    self.shouldForward = nil;
    self.joinedGroups = nil;
    self.routingTable = nil;
}


- (void)joinGroup:(NSString *)groupName
{
    if (groupName != nil && ![self.joinedGroups containsObject:groupName])
    {
        MHPacket *packet = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                           withDestinations:[[NSArray alloc] init]
                                                   withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [packet.info setObject:@"-[join-msg]-" forKey:@"message-type"];
        [packet.info setObject:groupName forKey:@"groupName"];
        [packet.info setObject:[[NSNumber alloc] initWithInt:0] forKey:@"height"];
        
        
        [self.joinMsgs setObject:packet forKey:packet.tag];
        [self.shouldForward setObject:[[NSNumber alloc] initWithBool:YES] forKey:packet.tag];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            [self.cHandler sendData:[packet asNSData] toPeers:self.neighbourPeers error:&error];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.joinedGroups addObject:groupName];
        });
    }
}

- (void)leaveGroup:(NSString *)groupName
{
    if (groupName != nil && [self.joinedGroups containsObject:groupName])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.joinedGroups removeObject:groupName];
        });
    }
}

- (void)disconnect
{
    [self.joinedGroups removeAllObjects];
    [self.joinMsgs removeAllObjects];
    [self.shouldForward removeAllObjects];
    [self.routingTable removeAllObjects];
    
    [super disconnect];
}

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{

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


@end