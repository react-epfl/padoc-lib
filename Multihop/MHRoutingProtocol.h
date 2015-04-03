//
//  MHRoutingProtocol.h
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHRoutingProtocol_h
#define Multihop_MHRoutingProtocol_h


#import <Foundation/Foundation.h>
#import "MHPacket.h"


@protocol MHRoutingProtocolDelegate;

@interface MHRoutingProtocol : NSObject

#pragma mark - Properties

@property (nonatomic, weak) id<MHRoutingProtocolDelegate> delegate;


#pragma mark - Initialization
- (instancetype)init;


- (void)discover;

- (void)disconnect;

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;




#pragma mark - ConnectionsHandler methods
- (void)hasConnected:(NSString *)info
                peer:(NSString *)peer;

- (void)hasDisconnected:(NSString *)info
                   peer:(NSString *)peer;


- (void)didReceivePacket:(MHPacket *)packet
                fromPeer:(NSString *)peer;

- (void)enteredStandby:(NSString *)info
                  peer:(NSString *)peer;

- (void)leavedStandby:(NSString *)info
                 peer:(NSString *)peer;

@end


@protocol MHRoutingProtocolDelegate <NSObject>

@required
- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName;

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
   hasDisconnected:(NSString *)info
              peer:(NSString *)peer;

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
        sendPacket:(MHPacket *)packet
           toPeers:(NSArray *)peers
             error:(NSError**)error;

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet;
@end


#endif
