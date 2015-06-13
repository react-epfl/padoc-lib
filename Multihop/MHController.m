//
//  MHController.m
//  Multihop
//
//  Created by quarta on 02/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHController.h"

@interface MHController () <MHRoutingProtocolDelegate>

@property (nonatomic, strong) MHRoutingProtocol *mhProtocol;
@end

@implementation MHController

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    self = [super init];
    if (self)
    {
        switch (protocol) {
            case MH6ShotsRoutingProtocol:
                self.mhProtocol = [[MH6ShotsProtocol alloc] initWithServiceType:serviceType
                                                                    displayName:displayName];
                break;
                
            case MHFloodingRoutingProtocol:
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
              error:(NSError **)error;
{
    MHPacket *packet = [[MHPacket alloc] initWithSource:[self getOwnPeer]
                                       withDestinations:destinations
                                               withData:[NSKeyedArchiver archivedDataWithRootObject:message]];
    
    [self.mhProtocol sendPacket:packet error:error];
}

- (void)joinGroup:(NSString *)groupName
{
    [(MHRoutingProtocol*)self.mhProtocol joinGroup:groupName];
}

- (void)leaveGroup:(NSString *)groupName
{
    [(MHRoutingProtocol*)self.mhProtocol leaveGroup:groupName];
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

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhController:self failedToConnect:error];
    });
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
     withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Unarchive message data
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:packet.data];
        
        if ([message isKindOfClass:[MHMessage class]])
        {
            [self.delegate mhController:self didReceiveMessage:message fromPeer:packet.source withTraceInfo:traceInfo];
        }
    });
}

#pragma mark - Diagnostics info callbacks
- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
     forwardPacket:(NSString *)info
        withPacket:(MHPacket *)packet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhController:self
                      forwardPacket:info
                        withMessage:[MHMessage fromNSData:packet.data]
                         fromSource:packet.source];
    });
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
       joinedGroup:(NSString *)info
              peer:(NSString *)peer
             group:(NSString *)group
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhController:self
                        joinedGroup:info
                               peer:peer
                              group:group];
    });
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
  neighbourConnected:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhController:self neighbourConnected:info peer:peer displayName:displayName];
    });
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
neighbourDisconnected:(NSString *)info
              peer:(NSString *)peer

{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhController:self neighbourDisconnected:info peer:peer];
    });
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhController:self
                       isDiscovered:info
                               peer:peer
                        displayName:displayName];
    });
}
@end