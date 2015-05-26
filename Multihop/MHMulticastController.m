//
//  MHMulticastController.m
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHMulticastController.h"

@interface MHMulticastController () <MHMulticastRoutingProtocolDelegate>

@property (nonatomic, strong) MHMulticastRoutingProtocol *mhProtocol;
@end

@implementation MHMulticastController

#pragma mark - Life Cycle

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

- (void)sendMessage:(MHMessage *)message
     toDestinations:(NSArray *)destinations
              error:(NSError **)error;
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
- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
       joinedGroup:(NSString *)info
              peer:(NSString *)peer
             group:(NSString *)group
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhMulticastController:self joinedGroup:info peer:peer group:group];
    });
}

- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhMulticastController:self failedToConnect:error];
    });
}

- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
     withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Unarchive message data
        id message = [NSKeyedUnarchiver unarchiveObjectWithData:packet.data];
        
        if ([message isKindOfClass:[MHMessage class]])
        {
            [self.delegate mhMulticastController:self didReceiveMessage:message fromPeer:packet.source withTraceInfo:traceInfo];
        }
    });
}

@end