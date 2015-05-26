//
//  MHMulticastSocket.m
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHMulticastSocket.h"


@interface MHMulticastSocket () <MHMulticastControllerDelegate>

@property (nonatomic, strong) MHMulticastController *mhController;
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
        self.mhController = [[MHMulticastController alloc] initWithServiceType:serviceType
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




#pragma mark - MHUnicastRoutingProtocol Delegates

- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
                  joinedGroup:(NSString *)info
                         peer:(NSString *)peer
                        group:(NSString *)group
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhMulticastSocket:joinedGroup:peer:group:)])
        {
            [self.delegate mhMulticastSocket:self joinedGroup:info peer:peer group:group];
        }
    });
}

- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
              failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhMulticastSocket:self failedToConnect:error];
    });
}

- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
            didReceiveMessage:(MHMessage *)message
                     fromPeer:(NSString *)peer
                withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhMulticastSocket:didReceiveMessage:fromPeer:withTraceInfo:)])
        {
            [self.delegate mhMulticastSocket:self didReceiveMessage:message.data fromPeer:peer withTraceInfo:traceInfo];
        }
    });
}

@end
