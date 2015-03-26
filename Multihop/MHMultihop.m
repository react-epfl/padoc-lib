//
//  MHMultihop.m
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHMultihop.h"


@interface MHMultihop () <MHConnectionsHandlerDelegate>

@property (nonatomic, strong) MHConnectionsHandler *cHandler;
@property (nonatomic, strong) MHBackgroundManager *bgManager;
@end

@implementation MHMultihop

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name];
}

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.cHandler = [[MHConnectionsHandler alloc] initWithServiceType:serviceType
                                                             displayName:displayName];
        self.cHandler.delegate = self;
        
        self.bgManager = [[MHBackgroundManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.cHandler  = nil;
    self.bgManager = nil;
}

#pragma mark - Membership

- (void)connectToAll
{
    [self.cHandler connectToAll];
}


- (void)disconnectFromAll
{
    [self.cHandler disconnectFromAll];
}

#pragma mark - Communicate

- (void)sendData:(NSData *)data
           error:(NSError **)error
{
    [self.cHandler sendData:data
                       error:error];
}

- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
           error:(NSError **)error
{
    [self.cHandler sendData:data
                     toPeers:peers
                       error:error];
}

- (NSString *)getOwnPeer
{
    return [self.cHandler getOwnPeer];
}


#pragma mark - Background Mode methods
- (void)applicationWillResignActive {
    [self.bgManager applicationWillResignActive];
}

- (void)applicationDidBecomeActive{
    [self.bgManager applicationDidBecomeActive];
}



# pragma mark - Termination method
- (void)applicationWillTerminate {
    [self.cHandler disconnectFromAll];
    self.cHandler = nil;
    self.bgManager = nil;
}




#pragma mark - MHConnectionsHandler Delegates
- (void)cHandler:(MHConnectionsHandler *)cHandler
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self hasDisconnected:info peer:peer];
    });
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self hasConnected:info peer:peer displayName:displayName];
    });
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
  failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self failedToConnect:error];
    });
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
   didReceiveData:(NSData *)data
         fromPeer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhHandler:didReceiveData:fromPeer:)])
        {
            [self.delegate mhHandler:self didReceiveData:data fromPeer:peer];
        }
    });
}

@end
