//
//  MHMulticastSocket.m
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHMulticastSocket.h"


@interface MHMulticastSocket () <MHMulticastRoutingProtocolDelegate>

@property (nonatomic, strong) MHMulticastRoutingProtocol *mhProtocol;
@end

@implementation MHMulticastSocket

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:MHMulticast6ShotsProtocol];
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                withRoutingProtocol:(MHMulticastProtocol)protocol
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:protocol];
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHMulticastProtocol)protocol
{
    self = [super init];
    if (self)
    {
        switch (protocol) {
            case MHMulticast6ShotsProtocol:
                self.mhProtocol = [[MH6ShotsProtocol alloc] initWithServiceType:serviceType
                                                                    displayName:displayName];
                break;
                
            default:
                self.mhProtocol = [[MH6ShotsProtocol alloc] initWithServiceType:serviceType
                                                                    displayName:displayName];
                break;
        }
        
        self.mhProtocol.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.mhProtocol  = nil;
}

#pragma mark - Membership

- (void)disconnect
{
    [self.mhProtocol disconnect];
}

#pragma mark - Communicate

- (void)joinGroup:(NSString *)groupName
{
    [self.mhProtocol joinGroup:groupName];
}

- (void)leaveGroup:(NSString *)groupName
{
    [self.mhProtocol leaveGroup:groupName];
}

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    [self.mhProtocol sendPacket:packet error:error];
}

- (NSString *)getOwnPeer
{
    return [self.mhProtocol getOwnPeer];
}




#pragma mark - Background Mode methods
- (void)applicationWillResignActive {
    [self.mhProtocol applicationWillResignActive];
}

- (void)applicationDidBecomeActive{
    [self.mhProtocol applicationDidBecomeActive];
}



# pragma mark - Termination method
- (void)applicationWillTerminate {
    [self disconnect];
}




#pragma mark - MHUnicastRoutingProtocol Delegates

- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhMulticastSocket:self failedToConnect:error];
    });
}

- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhMulticastSocket:didReceivePacket:)])
        {
            [self.delegate mhMulticastSocket:self didReceivePacket:packet];
        }
    });
}

@end
