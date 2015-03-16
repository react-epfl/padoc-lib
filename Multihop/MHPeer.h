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

@protocol MHPeerDelegate;


@interface MHPeer : NSObject

#pragma mark - Properties

/// Delegate for the PartyTime methods
@property (nonatomic, weak) id<MHPeerDelegate> delegate;


/// Returns the current client's MCPeerID (this ID is different for each
/// application startup)
@property (nonatomic, readonly, strong) MCPeerID *mcPeerID;

/// Returns the current client's MHPeerID (this ID is defined by the Multihop
/// library and remains consistent between different application startups)
@property (nonatomic, readonly, strong) NSString *mhPeerID;

/// Returns the display name which was passed in when the object was initialized.
/// If no display name was specified, it defaults to [UIDevice currentDevice].name]
@property (nonatomic, readonly, strong) NSString *displayName;


#pragma mark - Initialization


- (instancetype)init:(NSString *)displayName
     withOwnMCPeerID:(MCPeerID *)ownMCPeerID
        withMCPeerID:(MCPeerID *)mcPeerID
        withMHPeerID:(NSString *)mhPeerID;

@end



/**
 The delegate for the MHPeer class.
 */
@protocol MHPeerDelegate <NSObject>
/*
@required
- (void)partyTime:(PLPartyTime *)partyTime
             peer:(MCPeerID *)peer
     changedState:(MCSessionState)state
     currentPeers:(NSArray *)currentPeers;

- (void)partyTime:(PLPartyTime *)partyTime
failedToJoinParty:(NSError *)error;

@optional
- (void)partyTime:(PLPartyTime *)partyTime
   didReceiveData:(NSData *)data
         fromPeer:(MCPeerID *)peerID;

- (void)partyTime:(PLPartyTime *)partyTime
 didReceiveStream:(NSInputStream *)stream
         withName:(NSString *)streamName
         fromPeer:(MCPeerID *)peerID;

- (void)partyTime:(PLPartyTime *)partyTime
didStartReceivingResourceWithName:(NSString *)resourceName
         fromPeer:(MCPeerID *)peerID
     withProgress:(NSProgress *)progress;

- (void)partyTime:(PLPartyTime *)partyTime
didFinishReceivingResourceWithName:(NSString *)resourceName
         fromPeer:(MCPeerID *)peerID
            atURL:(NSURL *)localURL
        withError:(NSError *)error;
*/
@end

#endif

@end
