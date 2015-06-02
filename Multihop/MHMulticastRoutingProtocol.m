//
//  MHMulticastRoutingProtocol.m
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHMulticastRoutingProtocol.h"



@interface MHMulticastRoutingProtocol ()

@property (nonatomic, strong) NSString *displayName;
@end

@implementation MHMulticastRoutingProtocol

#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super initWithServiceType:serviceType displayName:displayName];
    if (self)
    {
        self.displayName = displayName;
    }
    return self;
}

- (void)dealloc
{
    self.displayName = nil;
}

- (void)disconnect
{
    [super disconnect];
}


#pragma mark - Overridable methods

- (void)joinGroup:(NSString *)groupName
{
    // Must be overridden
}
- (void)leaveGroup:(NSString *)groupName
{
    // Must be overridden
}

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

#pragma mark - ConnectionHandler delegate methods
// Every method must be overridden, except
// for failedToConnect
@end
