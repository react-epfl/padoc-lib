//
//  MHMultihop.m
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHMultihop.h"


@interface MHMultihop () <MHRouterDelegate>

@property (nonatomic, strong) MHRouter *mhRouter;
@end

@implementation MHMultihop

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:MHRoutingProtocolFlooding];
}

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHProtocol)protocol
{
    self = [super init];
    if (self)
    {
        self.mhRouter = [[MHRouter alloc] initWithServiceType:serviceType
                                                  displayName:displayName
                                          withRoutingProtocol:protocol];
        self.mhRouter.delegate = self;

    }
    return self;
}

- (void)dealloc
{
    self.mhRouter  = nil;
}

#pragma mark - Membership

- (void)discover
{
    [self.mhRouter discover];
}


- (void)disconnect
{
    [self.mhRouter disconnect];
}

#pragma mark - Communicate

- (void)sendPacket:(MHPacket *)packet
             error:(NSError *__autoreleasing *)error
{
    [self.mhRouter sendPacket:packet error:error];
}

- (NSString *)getOwnPeer
{
    return [self.mhRouter getOwnPeer];
}


#pragma mark - Background Mode methods
- (void)applicationWillResignActive {
    [self.mhRouter applicationWillResignActive];
}

- (void)applicationDidBecomeActive{
    [self.mhRouter applicationDidBecomeActive];
}



# pragma mark - Termination method
- (void)applicationWillTerminate {
    [self disconnect];
}




#pragma mark - MHConnectionsHandler Delegates

- (void)mhRouter:(MHRouter *)mhRouter
    isDiscovered:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self isDiscovered:info peer:peer displayName:displayName];
    });
}

- (void)mhRouter:(MHRouter *)mhRouter
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self hasDisconnected:info peer:peer];
    });
}

- (void)mhRouter:(MHRouter *)mhRouter
 failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self failedToConnect:error];
    });
}

- (void)mhRouter:(MHRouter *)mhRouter
didReceivePacket:(MHPacket *)packet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhHandler:didReceivePacket:)])
        {
            [self.delegate mhHandler:self didReceivePacket:packet];
        }
    });
}

@end
