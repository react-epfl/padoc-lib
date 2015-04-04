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
@property (nonatomic, strong) NSString *ownPeer;
@property (nonatomic, strong) NSString *displayName;


@property (nonatomic, strong) NSMutableArray *joinedGroups;
@property (nonatomic, strong) NSMutableDictionary *joinMsgs;
@property (nonatomic, strong) NSMutableDictionary *shouldForward;
@property (nonatomic, strong) NSMutableDictionary *routingTable;

@end

@implementation MH6ShotsProtocol

#pragma mark - Initialization
- (instancetype)initWithPeer:(NSString *)peer withDisplayName:(NSString *)displayName
{
    self = [super initWithPeer:peer withDisplayName:displayName];
    if (self)
    {
        self.joinedGroups = [[NSMutableArray alloc] init];

        
        self.routingTable = [[NSMutableDictionary alloc] init];
        [self.routingTable setObject:[[NSNumber alloc] initWithInt:0] forKey:self.ownPeer];
        
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


- (void)callSpecialRoutingFunctionWithName:(NSString *)name withArgs:(NSDictionary *)args
{
    if ([name isEqualToString:@"join"])
    {
        NSString *groupName = [args objectForKey:@"name"];
        
        if (groupName != nil && ![self.joinedGroups containsObject:groupName])
        {
            MHPacket *packet = [[MHPacket alloc] initWithSource:self.ownPeer
                                               withDestinations:[[NSArray alloc] init]
                                                       withData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [packet.info setObject:groupName forKey:@"groupName"];
            [packet.info setObject:[[NSNumber alloc] initWithInt:0] forKey:@"height"];
            
            
            [self.joinMsgs setObject:packet forKey:packet.tag];
            [self.shouldForward setObject:[[NSNumber alloc] initWithBool:YES] forKey:packet.tag];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                [self.delegate mhProtocol:self sendPacket:packet toPeers:self.neighbourPeers error:&error];
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.joinedGroups addObject:groupName];
            });
        }
    }
    else if([name isEqualToString:@"leave"])
    {
        NSString *groupName = [args objectForKey:@"name"];
        
        if (groupName != nil && [self.joinedGroups containsObject:groupName])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.joinedGroups removeObject:groupName];
            });
        }
    }
}

- (void)discover
{
    // Not supported
}

- (void)disconnect
{
    [super disconnect];
    
    [self.joinedGroups removeAllObjects];
    [self.joinMsgs removeAllObjects];
    [self.shouldForward removeAllObjects];
    [self.routingTable removeAllObjects];
}

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{

}




#pragma mark - ConnectionsHandler methods
- (void)hasConnected:(NSString *)info
                peer:(NSString *)peer
         displayName:(NSString *)displayName
{
    [super hasConnected:info peer:peer displayName:displayName];
}

- (void)hasDisconnected:(NSString *)info
                   peer:(NSString *)peer
{
    [super hasDisconnected:info peer:peer];
}


- (void)didReceivePacket:(MHPacket *)packet
                fromPeer:(NSString *)peer
{

}

- (void)enteredStandby:(NSString *)info
                  peer:(NSString *)peer
{
    
}

- (void)leavedStandby:(NSString *)info
                 peer:(NSString *)peer
{
    
}


@end