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

/// Query whether the client has joined the party
@property (nonatomic, readonly) BOOL connected;
/// Returns the current client's MHPeer
@property (nonatomic, readonly, strong) MHPeer *mhPeer;
/// Returns an array of MHPeers which represents the connected peers. Doesn't include the current client's peer.
@property (nonatomic, readonly) NSArray *connectedPeers;
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
 
 - (instancetype)initWithServiceType:(NSString *)serviceType displayName:(NSString *)displayName;
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 
 @param displayName The display name which is sent to other clients in the party.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

/**
 Call this method to connect to all peers. It will automatically start searching for peers.
 
 When you successfully connect to another peer, you will receive a delegate callback to:
 
 - (void)partyTime:(PLPartyTime *)partyTime peer:(MCPeerID *)peer changedState:(MCSessionState)state currentPeers:(NSArray *)currentPeers;
 */
- (void)connectToAll;

/**
 Call this method stop accepting invitations from peers. You will not disconnect from the party, but will not allow incoming connections.
 
 To start searching for peers again, call the connectToAll method again.
 */
- (void)stopAcceptingConnections;

/**
 Call this method to disconnect from everyone. You can reconnect at any time using the connectToAll method.
 */
- (void)disconnectFromAll;

/**
 Sends data to select peers.
 
 They will receive the data with the delegate callback:
 
 - (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;
 
 @param data Data to send.
 @param mode The transmission mode to use (reliable or unreliable delivery).
 @param error The address of an NSError pointer where an error object should be stored upon error.
 @return Returns YES if the message was successfully enqueued for delivery, or NO if an error occurred.
 
 */
- (void)sendData:(NSData *)data
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error;

/**
 Sends data to select peers.
 
 They will receive the data with the delegate callback:
 
 - (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;
 
 @param data Data to send.
 @param peerIDs An array of MCPeerID objects to send data to.
 @param mode The transmission mode to use (reliable or unreliable delivery).
 @param error The address of an NSError pointer where an error object should be stored upon error.
 @return Returns YES if the message was successfully enqueued for delivery, or NO if an error occurred.
 
 */
- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error;

@end

/**
 The delegate for the MHMultipeerWrapperDelegate class.
 */
@protocol MHMultipeerWrapperDelegate <NSObject>

@required
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
             peer:(MHPeer *)peer
     changedState:(NSString *)state
     currentPeers:(NSArray *)currentPeers;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  failedToConnect:(NSError *)error;

@optional
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
   didReceiveData:(NSData *)data
         fromPeer:(NSString *)peer;
@end



#endif
