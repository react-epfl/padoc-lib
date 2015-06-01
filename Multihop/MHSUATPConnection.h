//
//  MHSUATPConnection.h
//  Multihop
//
//  Created by quarta on 16/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHSUATPConnection_h
#define Multihop_MHSUATPConnection_h


#import <Foundation/Foundation.h>
#import "MHComputation.h"
#import "MHMessage.h"
#import "MHSUATPBuffer.h"
#import "MHSUATPAckMessageContent.h"

#define MH_SUATP_MAX_INITIAL_SEQ_NUMBER 100000
#define MH_SUATP_TIMEOUT_MS 3000


#define MH_SUATP_DEFAULT_SENDING_DELAY 20
//#define MH_SUATP_DEFAULT_RECEIVING_DELAY 20


@protocol MHSUATPConnectionDelegate;

@interface MHSUATPConnection : NSObject

#pragma mark - Properties


@property (nonatomic, weak) id<MHSUATPConnectionDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithTargetPeer:(NSString*)targetPeer;


- (void)handshake;

- (void)sendMessage:(MHMessage *)message;

- (void)messageReceived:(MHMessage *)message
          withTraceInfo:(NSArray *)traceInfo;


@end

/**
 The delegate for the MHSUATPConnection class.
 */
@protocol MHSUATPConnectionDelegate <NSObject>

@required
- (void)MHSUATPConnection:(MHSUATPConnection *)MHSUATPConnection
                      isDisconnected:(NSString *)info
                                peer:(NSString *)peer;

// Tells the lower layers to send a packet containing the specified message
- (void)MHSUATPConnection:(MHSUATPConnection *)MHSUATPConnection
                         sendMessage:(MHMessage *)message
                              toPeer:(NSString *)peer;

// Needs to be directly forwarded to upper layers
- (void)MHSUATPConnection:(MHSUATPConnection *)MHSUATPConnection
                   didReceiveMessage:(MHMessage *)message
                            fromPeer:(NSString *)peer
                       withTraceInfo:(NSArray *)traceInfo;
@end


#endif

