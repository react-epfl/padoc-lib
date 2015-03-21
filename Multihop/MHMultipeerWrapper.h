//
//  MHNodeManager.h
//  Multihop
//
//  Created by quarta on 16/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHMultipeerWrapper_h
#define Multihop_MHMultipeerWrapper_h


#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MHPeer.h"

@protocol MHMultipeerWrapperDelegate;

@interface MHMultipeerWrapper : NSObject

#pragma mark - Properties

/// Delegate for the MHMultipeerWrapper methods
@property (nonatomic, weak) id<MHMultipeerWrapperDelegate> delegate;

/// Returns the current client's MHPeer
/// Returns the serviceType which was passed in when the object was initialized.
@property (nonatomic, readonly, strong) NSString *serviceType;


#pragma mark - Initialization

/**
 Init method for this class.
 
 You must initialize this method with this method or:
 
 - (instancetype)initWithServiceType:(NSString *)serviceType displayName:(NSString *)displayName;
 
 Since you are not passing in a display name, it will default to:
 
 [UIDevice currentDevice].name]
 
 Which returns a string similar to: @"Peter's iPhone".
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType;

/**
 Init method for this class.
 
 You must initialize this method with this method or:
 
 - (instancetype)initWithServiceType:(NSString *)serviceType;
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 
 @param displayName The display name which is sent to other peers.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

/**
 Call this method to connect to all peers. It will automatically start searching for peers.
 
 When you successfully connect to another peer, you will receive a delegate callback to:
 
 - (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper hasConnected:(NSString *)info peer:(NSString *)peer displayName:(NSString *)displayName;
 */
- (void)connectToAll;


/**
 Call this method to disconnect from everyone. You can reconnect at any time using the connectToAll method.
 */
- (void)disconnectFromAll;

/**
 Broadcast data to all connected peers.
 
 They will receive the data with the delegate callback:
 
 - (void)partyTime:(MHMultipeerWrapper *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;
 
 @param data Data to send.
 @param reliable Boolean defining the transmission mode to use (reliable or unreliable delivery).
 @param error The address of an NSError pointer where an error object should be stored upon error.
 
 */
- (void)sendData:(NSData *)data
        reliable:(BOOL)reliable
           error:(NSError **)error;

/**
 Sends data to selected peers.
 
 They will receive the data with the delegate callback:
 
 - (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper didReceiveData:(NSData *)data fromPeer:(NSString *)peer;
 
 @param data Data to send.
 @param to^Peers An array of MHPeerID (strings) to send data to.
 @param reliable Boolean defining the transmission mode to use (reliable or unreliable delivery).
 @param error The address of an NSError pointer where an error object should be stored upon error.
 
 */
- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
        reliable:(BOOL)reliable
           error:(NSError **)error;

- (NSString *)getOwnPeer;

@end

/**
 The delegate for the MHMultipeerWrapperDelegate class.
 */
@protocol MHMultipeerWrapperDelegate <NSObject>

@required
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  failedToConnect:(NSError *)error;

@optional
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
   didReceiveData:(NSData *)data
         fromPeer:(NSString *)peer;
@end



#endif
