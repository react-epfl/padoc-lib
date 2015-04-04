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

@end

@implementation MH6ShotsProtocol

#pragma mark - Initialization
- (instancetype)initWithPeer:(NSString *)peer withDisplayName:(NSString *)displayName
{
    self = [super initWithPeer:peer withDisplayName:displayName];
    if (self)
    {
        self.joinedGroups = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{

}


- (void)callSpecialRoutingFunctionWithName:(NSString *)name withArgs:(NSDictionary *)args
{
    if ([name isEqualToString:@"join"])
    {
        NSString *name = [args objectForKey:@"name"];
        
        if (name != nil && ![self.joinedGroups containsObject:name])
        {
            [self.joinedGroups addObject:name];
        }
    }
    else if([name isEqualToString:@"leave"])
    {
        NSString *name = [args objectForKey:@"name"];
        
        if (name != nil && [self.joinedGroups containsObject:name])
        {
            [self.joinedGroups removeObject:name];
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