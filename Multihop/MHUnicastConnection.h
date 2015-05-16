//
//  MHUnicastConnection.h
//  Multihop
//
//  Created by quarta on 16/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHUnicastConnection_h
#define Multihop_MHUnicastConnection_h


#import <Foundation/Foundation.h>
#import "MHUnicastRoutingProtocol.h"
#import "MHMessage.h"



@protocol MHUnicastConnectionDelegate;

@interface MHUnicastConnection : NSObject

#pragma mark - Properties


@property (nonatomic, weak) id<MHUnicastConnectionDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithRoutingProtocol:(MHUnicastRoutingProtocol*)protocol
                            withOwnPeer:(NSString*)ownPeer
                         withTargetPeer:(NSString*)targetPeer;


- (void)handshake;

- (void)sendMessage:(MHMessage *)message
              error:(NSError **)error;

- (void)messageReceived:(MHMessage *)message
          withTraceInfo:(NSArray *)traceInfo;


@end

/**
 The delegate for the MHUnicastConnection class.
 */
@protocol MHUnicastConnectionDelegate <NSObject>

@required
- (void)mhUnicastConnection:(MHUnicastConnection *)mhUnicastConnection
             isDisconnected:(NSString *)info
                       peer:(NSString *)peer;

- (void)mhUnicastConnection:(MHUnicastConnection *)mhUnicastConnection
          didReceiveMessage:(MHMessage *)message
                   fromPeer:(NSString *)peer
              withTraceInfo:(NSArray *)traceInfo;
@end


#endif

