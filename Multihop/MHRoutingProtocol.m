//
//  MHRoutingProtocol.m
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHRoutingProtocol.h"



@interface MHRoutingProtocol ()

@property (nonatomic, strong) NSMutableArray *neighbourPeers;
@property (nonatomic, strong) NSString *ownPeer;
@property (nonatomic, strong) NSString *displayName;
@end

@implementation MHRoutingProtocol

#pragma mark - Initialization
- (instancetype)initWithPeer:(NSString *)peer withDisplayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.neighbourPeers = [[NSMutableArray alloc] init];
        self.ownPeer = peer;
        self.displayName = displayName;
    }
    return self;
}

- (void)dealloc
{
    self.neighbourPeers = nil;
}


- (void)discover
{
    
}

- (void)disconnect
{
    [self.neighbourPeers removeAllObjects];
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
    [self.neighbourPeers addObject:peer];
}

- (void)hasDisconnected:(NSString *)info
                   peer:(NSString *)peer
{
    [self.neighbourPeers removeObject:peer];
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
