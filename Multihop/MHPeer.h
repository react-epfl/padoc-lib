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

@property (nonatomic, readonly, strong) MCSession *session;

#pragma mark - Initialization


- (instancetype)initWithDisplayName:(NSString *)displayName
     withOwnMCPeerID:(MCPeerID *)ownMCPeerID
        withMCPeerID:(MCPeerID *)mcPeerID
        withMHPeerID:(NSString *)mhPeerID;

+ (MHPeer *)getOwnMHPeerWithDisplayName:(NSString *)displayName;
+ (NSString *)stringForPeerConnectionState:(MCSessionState)state;

@end



/**
 The delegate for the MHPeer class.
 */
@protocol MHPeerDelegate <NSObject>

@required
- (void)mhPeer:(MHPeer *)mhPeer
  changedState:(NSString *)state;

@optional
- (void)mhPeer:(MHPeer *)mhPeer
didReceiveData:(NSData *)data;

@end

#endif
