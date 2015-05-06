//
//  MHUnicastController.m
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHUnicastController.h"


@interface MHUnicastController () <MHUnicastRoutingProtocolDelegate>

@property (nonatomic, strong) MHUnicastRoutingProtocol *mhProtocol;
@end

@implementation MHUnicastController

#pragma mark - Life Cycle
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHUnicastProtocol)protocol
{
    self = [super init];
    if (self)
    {
        switch (protocol) {
            case MHUnicastFloodingProtocol:
                self.mhProtocol = [[MHFloodingProtocol alloc] initWithServiceType:serviceType
                                                                      displayName:displayName];
                break;
                
            default:
                self.mhProtocol = [[MHFloodingProtocol alloc] initWithServiceType:serviceType
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

- (void)sendMessage:(MHMessage *)message
     toDestinations:(NSArray *)destinations
              error:(NSError **)error
{
    MHPacket *packet = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                       withDestinations:destinations
                                               withData:[NSKeyedArchiver archivedDataWithRootObject:message]];
    
    [self.mhProtocol sendPacket:packet error:error];
}

- (NSString *)getOwnPeer
{
    return [self.mhProtocol getOwnPeer];
}

- (int)hopsCountFromPeer:(NSString*)peer
{
    return [self.mhProtocol hopsCountFromPeer:peer];
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

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self isDiscovered:info peer:peer displayName:displayName];
    });
}

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   hasDisconnected:(NSString *)info
              peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self hasDisconnected:info peer:peer];
    });
}

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastController:self failedToConnect:error];
    });
}

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
     withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Unarchive message data
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:packet.data];
        
        if ([message isKindOfClass:[MHMessage class]])
        {
            [self.delegate mhUnicastController:self didReceiveMessage:message fromPeer:packet.source withTraceInfo:traceInfo];
        }
    });
}

@end