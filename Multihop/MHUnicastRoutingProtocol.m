//
//  MHUnicastRoutingProtocol.m
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHUnicastRoutingProtocol.h"



@interface MHUnicastRoutingProtocol ()

@end

@implementation MHUnicastRoutingProtocol

#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super initWithServiceType:serviceType displayName:displayName];
    if (self)
    {

    }
    return self;
}

- (void)dealloc
{

}

- (void)disconnect
{
    [super disconnect];
}


#pragma mark - Overridable methods

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    // Must be overridden
}

- (int)hopsCountFromPeer:(NSString*)peer
{
    // Must be overridden
    return 0;
}


#pragma mark - ConnectionsHandler delegate methods
// Every method must be overridden, except
// for failedToConnect
@end
