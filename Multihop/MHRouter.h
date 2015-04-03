//
//  MHRouter.h
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHRouter_h
#define Multihop_MHRouter_h


#import <Foundation/Foundation.h>
#import "MHConnectionsHandler.h"
#import "MHRoutingProtocol.h"
#import "MHPacket.h"


typedef enum MHProtocol
{
    MHRoutingProtocolFlooding,
    MHRoutingProtocol6Shots
} MHProtocol;


@protocol MHRouterDelegate;

@interface MHRouter : NSObject

#pragma mark - Properties

/// Delegate for the MHMultihop methods
@property (nonatomic, weak) id<MHRouterDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHProtocol)protocol;


- (void)discover;

- (void)disconnect;

- (void)sendPacket:(MHPacket *)packet
           error:(NSError **)error;

- (NSString *)getOwnPeer;




// Background Mode methods
- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;


@end


@protocol MHRouterDelegate <NSObject>

@required
- (void)mhRouter:(MHRouter *)mhRouter
    isDiscovered:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName;

- (void)mhRouter:(MHRouter *)mhRouter
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer;

- (void)mhRouter:(MHRouter *)mhRouter
 failedToConnect:(NSError *)error;

- (void)mhRouter:(MHRouter *)mhRouter
  didReceivePacket:(MHPacket *)packet;
@end

#endif
