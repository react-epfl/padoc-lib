/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHPeer_h
#define Padoc_MHPeer_h

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "MHDatagram.h"
#import "MHPeerBuffer.h"

#import "MHConfig.h"


#define MHPEER_HEARTBEAT_MSG  @"[{_-heartbeat_msg-_}]"
#define MHPEER_CONGESTION_CONTROL_MSG  @"[{_-congestion_control_msg-_}]"
#define MHPEER_HEARTBEAT_CONGESTION_CONTROL_MSG  @"[{_-heartbeat_congestion_control_msg-_}]"

#define MHPEER_STARTHEARTBEAT_TIME 15

#define MHPEER_RECEIVING_DELAY_PRECISION 200
#define MHPEER_RECEIVING_HEARTBEAT_DELAY_PRECISION 500

#define MHPEER_HEARTBEAT_DECREASE_AMOUNT 50


@protocol MHPeerDelegate;


@interface MHPeer : NSObject

#pragma mark - Properties

/// Delegate for the PartyTime methods
@property (nonatomic, weak) id<MHPeerDelegate> delegate;

@property (nonatomic, readonly, strong) MCPeerID *mcPeerID;
@property (nonatomic, readonly, strong) NSString *mhPeerID;
@property (nonatomic, readonly, strong) NSString *displayName;

@property (nonatomic, readonly, strong) MCSession *session;

#pragma mark - Initialization


- (instancetype)initWithDisplayName:(NSString *)displayName
     withOwnMCPeerID:(MCPeerID *)ownMCPeerID
     withOwnMHPeerID:(NSString *)ownMHPeerID
        withMCPeerID:(MCPeerID *)mcPeerID
        withMHPeerID:(NSString *)mhPeerID;

- (void)sendDatagram:(MHDatagram *)datagram
               error:(NSError **)error;

- (void)disconnect;

+ (MHPeer *)getOwnMHPeerWithDisplayName:(NSString *)displayName;

@end



/**
 The delegate for the MHPeer class.
 */
@protocol MHPeerDelegate <NSObject>

@required
- (void)mhPeer:(MHPeer *)mhPeer
hasDisconnected:(NSString *)info;

- (void)mhPeer:(MHPeer *)mhPeer
hasConnected:(NSString *)info;

- (void)mhPeer:(MHPeer *)mhPeer
didReceiveDatagram:(MHDatagram *)datagram;

@end

#endif
