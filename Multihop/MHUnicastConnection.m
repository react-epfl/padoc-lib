//
//  MHUnicastConnection.m
//  Multihop
//
//  Created by quarta on 16/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHUnicastConnection.h"



@interface MHUnicastConnection ()

@property (nonatomic, strong) MHUnicastRoutingProtocol *mhProtocol;
@property (nonatomic, strong) NSString *ownPeer;
@property (nonatomic, strong) NSString *targetPeer;
@end

@implementation MHUnicastConnection

#pragma mark - Life Cycle
- (instancetype)initWithRoutingProtocol:(MHUnicastRoutingProtocol*)protocol
                            withOwnPeer:(NSString*)ownPeer
                         withTargetPeer:(NSString*)targetPeer
{
    self = [super init];
    if (self)
    {
        self.mhProtocol = protocol;
        self.ownPeer = ownPeer;
        self.targetPeer = targetPeer;
    }
    return self;
}

- (void)dealloc
{
    self.mhProtocol  = nil;
}


#pragma mark - Communicate

- (void)handshake
{
    
}

- (void)sendMessage:(MHMessage *)message
              error:(NSError **)error
{
    MHPacket *packet = [[MHPacket alloc] initWithSource:self.ownPeer
                                       withDestinations:[[NSArray alloc] initWithObjects:self.targetPeer, nil]
                                               withData:[NSKeyedArchiver archivedDataWithRootObject:message]];
    
    [self.mhProtocol sendPacket:packet error:error];
}

- (void)messageReceived:(MHMessage *)message
          withTraceInfo:(NSArray *)traceInfo
{
    
}

@end