//
//  MHMultihop.m
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHUnicastSocket.h"


@interface MHUnicastSocket () <MHUnicastControllerDelegate>

@property (nonatomic, strong) MHUnicastController *mhController;

@end

@implementation MHUnicastSocket

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:MHUnicastFloodingProtocol];
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                withRoutingProtocol:(MHUnicastProtocol)protocol
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:protocol];
}


- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHUnicastProtocol)protocol
{
    self = [super init];
    if (self)
    {
        self.mhController = [[MHUnicastController alloc] initWithServiceType:serviceType
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

#pragma mark - Membership

- (void)disconnect
{
    [self.mhController disconnect];
}


#pragma mark - Communicate

- (void)sendMessage:(NSData *)data
     toDestinations:(NSArray *)destinations
              error:(NSError **)error
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




#pragma mark - MHUnicastController Delegates
- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
               isDiscovered:(NSString *)info
                       peer:(NSString *)peer
                displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastSocket:self isDiscovered:info peer:peer displayName:displayName];
    });
}

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
            hasDisconnected:(NSString *)info
                       peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastSocket:self hasDisconnected:info peer:peer];
    });
}

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
            failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhUnicastSocket:self failedToConnect:error];
    });
}

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
          didReceiveMessage:(MHMessage *)message
                   fromPeer:(NSString *)peer
              withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhUnicastSocket:didReceiveMessage:fromPeer:withTraceInfo:)])
        {
            [self.delegate mhUnicastSocket:self didReceiveMessage:message.data fromPeer:peer withTraceInfo:traceInfo];
        }
    });
}

@end
