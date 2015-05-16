//
//  MHUnicastTransportConnection.h
//  Multihop
//
//  Created by quarta on 16/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHUnicastTransportConnection_h
#define Multihop_MHUnicastTransportConnection_h


#import <Foundation/Foundation.h>
#import "MHComputation.h"
#import "MHMessage.h"

#define MH_SUATP_MAX_INITIAL_SEQ_NUMBER 100000

@protocol MHUnicastTransportConnectionDelegate;

@interface MHUnicastTransportConnection : NSObject

#pragma mark - Properties


@property (nonatomic, weak) id<MHUnicastTransportConnectionDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithTargetPeer:(NSString*)targetPeer;


- (void)handshake;

- (void)sendMessage:(MHMessage *)message;

- (void)messageReceived:(MHMessage *)message
          withTraceInfo:(NSArray *)traceInfo;


@end

/**
 The delegate for the MHUnicastTransportConnection class.
 */
@protocol MHUnicastTransportConnectionDelegate <NSObject>

@required
- (void)MHUnicastTransportConnection:(MHUnicastTransportConnection *)MHUnicastTransportConnection
             isDisconnected:(NSString *)info
                       peer:(NSString *)peer;

// Tells the lower layers to send a packet containing the specified message
- (void)MHUnicastTransportConnection:(MHUnicastTransportConnection *)MHUnicastTransportConnection
                         sendMessage:(MHMessage *)message
                              toPeer:(NSString *)peer;

// Needs to be directly forwarded to upper layers
- (void)MHUnicastTransportConnection:(MHUnicastTransportConnection *)MHUnicastTransportConnection
          didReceiveMessage:(MHMessage *)message
                   fromPeer:(NSString *)peer
              withTraceInfo:(NSArray *)traceInfo;
@end


#endif

