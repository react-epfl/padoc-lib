//
//  MHRouter.m
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHRouter.h"



@interface MHRouter () <MHConnectionsHandlerDelegate, MHRoutingProtocolDelegate>

@property (nonatomic, strong) MHConnectionsHandler *cHandler;
@property (nonatomic, strong) MHRoutingProtocol *protocol;
@end

@implementation MHRouter



#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHProtocol)protocol
{
    self = [super init];
    if (self)
    {
        self.cHandler = [[MHConnectionsHandler alloc] initWithServiceType:serviceType
                                                              displayName:displayName];
        self.cHandler.delegate = self;
        
        switch (protocol) {
            case MHRoutingProtocolFlooding:
                self.protocol = [[MHFloodingProtocol alloc] initWithPeer:[self getOwnPeer] withDisplayName:displayName];
                break;
            case MHRoutingProtocol6Shots:
                
                break;
            default:
                self.protocol = [[MHFloodingProtocol alloc] initWithPeer:[self getOwnPeer] withDisplayName:displayName];
                break;
        }
        
        self.protocol.delegate = self;
        
        [self.cHandler connectToAll];
    }
    return self;
}

- (void)dealloc
{
    self.cHandler = nil;
    self.protocol = nil;
}

#pragma mark - Membership

- (void)discover
{
    [self.protocol discover];
}


- (void)disconnect
{
    [self.protocol disconnect];
    [self.cHandler disconnectFromAll];
}

#pragma mark - Communicate

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error
{
    [self.protocol sendPacket:packet error:error];
}

- (NSString *)getOwnPeer
{
    return [self.cHandler getOwnPeer];
}


- (void)callSpecialRoutingFunctionWithName:(NSString *)name withArgs:(NSDictionary *)args
{
    [self.protocol callSpecialRoutingFunctionWithName:name withArgs:args];
}


#pragma mark - Background Mode methods
- (void)applicationWillResignActive {
    [self.cHandler applicationWillResignActive];
}

- (void)applicationDidBecomeActive{
    [self.cHandler applicationDidBecomeActive];
}




#pragma mark - MHConnectionsHandler Delegates
- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
    [self.protocol hasConnected:info peer:peer displayName:displayName];
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    [self.protocol hasDisconnected:info peer:peer];
}


- (void)cHandler:(MHConnectionsHandler *)cHandler
 failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhRouter:self failedToConnect:error];
    });
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
  didReceiveData:(NSData *)data
        fromPeer:(NSString *)peer
{
    [self.protocol didReceivePacket:[MHPacket fromNSData:data] fromPeer:peer];
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
  enteredStandby:(NSString *)info
            peer:(NSString *)peer
{
    [self.protocol enteredStandby:info peer:peer];
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
   leavedStandby:(NSString *)info
            peer:(NSString *)peer
{
    [self.protocol leavedStandby:info peer:peer];
}



#pragma mark - MHRoutingProtocol delegates
- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhRouter:self isDiscovered:info peer:peer displayName:displayName];
    });
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
   hasDisconnected:(NSString *)info
              peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhRouter:self hasDisconnected:info peer:peer];
    });
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
        sendPacket:(MHPacket *)packet
           toPeers:(NSArray *)peers
             error:(NSError**)error
{
    [self.cHandler sendData:[packet asNSData] toPeers:peers error:error];
}

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhRouter:self didReceivePacket:packet];
    });
}

@end
