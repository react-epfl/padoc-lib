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
    // Must be overridden
    return nil;
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    // Must be overridden
    return nil;
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    self.mhController  = nil;
}

#pragma mark - Membership

- (void)disconnect
{
    [self.mhController disconnect];
}

#pragma mark - Communicate

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
            fromPeer:(NSString *)peer
       withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhSocket:didReceiveMessage:fromPeer:withTraceInfo:)])
        {
            [self.delegate mhSocket:self didReceiveMessage:message.data fromPeer:peer withTraceInfo:traceInfo];
        }
    });
}

#pragma mark - Diagnostics info callbacks
- (void)mhController:(MHController *)mhController
       forwardPacket:(NSString *)info
          fromSource:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhSocket:forwardPacket:fromSource:)])
        {
            [self.delegate mhSocket:self forwardPacket:info fromSource:peer];
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
@end
