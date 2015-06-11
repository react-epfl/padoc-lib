//
//  MHPeer.h
//  Multihop
//
//  Created by quarta on 16/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHPeer_h
#define Multihop_MHPeer_h

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#include <stdlib.h>

#define MHPEER_HEARTBEAT_TIME_RANGE 1
#define MHPEER_HEARTBEAT_TIME_BASE 1
#define MHPEER_MAX_HEARTBEAT_FAILS 3

#define MHPEER_HEARTBEAT_MSG  @"[{_-heartbeat_msg-_}]"
#define MHPEER_ACK_MSG @"[{_-heartbeat_ack-_}]"

#define MHPEER_STARTHEARTBEAT_TIME 10


@protocol MHPeerDelegate;


@interface MHPeer : NSObject

#pragma mark - Properties

/// Delegate for the PartyTime methods
@property (nonatomic, weak) id<MHPeerDelegate> delegate;

@property (nonatomic, readonly) BOOL connected;

/// Returns the current client's MCPeerID (this ID is different for each
/// application startup)
@property (nonatomic, readonly, strong) MCPeerID *mcPeerID;

/// Returns the current client's MHPeerID (this ID is defined by the Multihop
/// library and remains consistent between different application startups)
@property (nonatomic, readonly, strong) NSString *mhPeerID;

/// Returns the display name which was passed in when the object was initialized.
/// If no display name was specified, it defaults to [UIDevice currentDevice].name]
@property (nonatomic, readonly, strong) NSString *displayName;

@property (nonatomic, readonly, strong) MCSession *session;

#pragma mark - Initialization


- (instancetype)initWithDisplayName:(NSString *)displayName
     withOwnMCPeerID:(MCPeerID *)ownMCPeerID
     withOwnMHPeerID:(NSString *)ownMHPeerID
        withMCPeerID:(MCPeerID *)mcPeerID
        withMHPeerID:(NSString *)mhPeerID;

- (void)sendData:(NSData *)data
        reliable:(BOOL)reliable
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
didReceiveData:(NSData *)data;

@end

#endif
