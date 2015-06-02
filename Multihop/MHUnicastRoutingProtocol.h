//
//  MHUnicastRoutingProtocol.h
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHUnicastRoutingProtocol_h
#define Multihop_MHUnicastRoutingProtocol_h


#import <Foundation/Foundation.h>
#import "MHRoutingProtocol.h"


@protocol MHUnicastRoutingProtocolDelegate;

@interface MHUnicastRoutingProtocol : MHRoutingProtocol


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

#pragma mark - Overridable methods
- (void)disconnect;

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;

- (int)hopsCountFromPeer:(NSString*)peer;

@end


@protocol MHUnicastRoutingProtocolDelegate <MHRoutingProtocolDelegate>

@required
- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName;

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   hasDisconnected:(NSString *)info
              peer:(NSString *)peer;
@end


#endif
