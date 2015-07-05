//
//  MHSocket.m
//  Multihop
//
//  Created by quarta on 02/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHSocket.h"


@interface MHSocket () <MHControllerDelegate>

@property (nonatomic, strong) MHController *mhController;
@end

@implementation MHSocket

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:MHFloodingRoutingProtocol];
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:protocol];
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    self = [super init];
    if (self)
    {
        self.mhController = [[MHController alloc] initWithServiceType:serviceType
                                                          displayName:displayName
                                                  withRoutingProtocol:protocol];
        
        self.mhController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.mhController  = nil;
}


#pragma mark - Communicate

- (void)disconnect
{
    [self.mhController disconnect];
}

- (void)joinGroup:(NSString *)groupName
{
    [self.mhController joinGroup:groupName];
}

- (void)leaveGroup:(NSString *)groupName
{
    [self.mhController leaveGroup:groupName];
}


- (void)sendMessage:(NSData *)data
     toDestinations:(NSArray *)destinations
              error:(NSError **)error;
{
    MHMessage *message = [[MHMessage alloc] initWithData:data];
    
    [self.mhController sendMessage:message toDestinations:destinations error:error];
}



- (NSString *)getOwnPeer
{
    return [self.mhController getOwnPeer];
}

- (int)hopsCountFromPeer:(NSString*)peer
{
    return [self.mhController hopsCountFromPeer:peer];
}



#pragma mark - Background Mode methods
- (void)applicationWillResignActive {
    [self.mhController applicationWillResignActive];
}

- (void)applicationDidBecomeActive{
    [self.mhController applicationDidBecomeActive];
}



# pragma mark - Termination method
- (void)applicationWillTerminate {
    [self disconnect];
}




#pragma mark - MHController Delegates

- (void)mhController:(MHController *)mhController
     failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhSocket:self failedToConnect:error];
    });
}

- (void)mhController:(MHController *)mhController
   didReceiveMessage:(MHMessage *)message
          fromGroups:(NSArray *)groups
       withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhSocket:self didReceiveMessage:message.data fromGroups:groups withTraceInfo:traceInfo];
    });
}



#pragma mark - Diagnostics info callbacks
- (void)mhController:(MHController *)mhController
       forwardPacket:(NSString *)info
         withMessage:(MHMessage *)message
          fromSource:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhSocket:forwardPacket:withMessage:fromSource:)])
        {
            [self.delegate mhSocket:self
                      forwardPacket:info
                        withMessage:message.data
                         fromSource:peer];
        }
    });
}

- (void)mhController:(MHController *)mhController
  neighbourConnected:(NSString *)info
                peer:(NSString *)peer
         displayName:(NSString *)displayName

{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhSocket:neighbourConnected:peer:displayName:)])
        {
            [self.delegate mhSocket:self neighbourConnected:info peer:peer displayName:displayName];
        }
    });
}

- (void)mhController:(MHController *)mhController
neighbourDisconnected:(NSString *)info
                peer:(NSString *)peer

{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhSocket:neighbourDisconnected:peer:)])
        {
            [self.delegate mhSocket:self neighbourDisconnected:info peer:peer];
        }
    });
}

- (void)mhController:(MHController *)mhController
         joinedGroup:(NSString *)info
                peer:(NSString *)peer
         displayName:(NSString *)displayName
               group:(NSString *)group
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhSocket:joinedGroup:peer:displayName:group:)])
        {
            [self.delegate mhSocket:self
                        joinedGroup:info
                               peer:peer
                        displayName:displayName
                              group:group];
        }
    });
}
@end
