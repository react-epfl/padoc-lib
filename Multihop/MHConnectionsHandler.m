//
//  MHConnectionsHandler.m
//  consoleViewer
//
//  Created by quarta on 25/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHConnectionsHandler.h"


@interface MHConnectionsHandler () <MHMultipeerWrapperDelegate>

@property (nonatomic, strong) MHMultipeerWrapper *mcWrapper;

@end

@implementation MHConnectionsHandler

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.mcWrapper = [[MHMultipeerWrapper alloc] initWithServiceType:serviceType
                                                             displayName:displayName];
        self.mcWrapper.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.mcWrapper  = nil;
}

#pragma mark - Membership

- (void)connectToAll
{
    [self.mcWrapper connectToAll];
}


- (void)disconnectFromAll
{
    [self.mcWrapper disconnectFromAll];
}

#pragma mark - Communicate

- (void)sendData:(NSData *)data
           error:(NSError **)error
{
    [self.mcWrapper sendData:data
                    reliable:YES
                       error:error];
}

- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
           error:(NSError **)error
{
    [self.mcWrapper sendData:data
                     toPeers:peers
                    reliable:YES
                       error:error];
}

- (NSString *)getOwnPeer
{
    return [self.mcWrapper getOwnPeer];
}



#pragma mark - MHMultipeerWrapper Delegates
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate cHandler:self hasDisconnected:info peer:peer];
    });
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate cHandler:self hasConnected:info peer:peer displayName:displayName];
    });
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate cHandler:self failedToConnect:error];
    });
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
   didReceiveData:(NSData *)data
         fromPeer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(cHandler:didReceiveData:fromPeer:)])
        {
            [self.delegate cHandler:self didReceiveData:data fromPeer:peer];
        }
    });
}

@end