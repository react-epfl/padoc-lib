//
//  MHMulticastSocket.h
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHMulticastSocket_h
#define Multihop_MHMulticastSocket_h

#import <Foundation/Foundation.h>
#import "MHMulticastController.h"


@protocol MHMulticastSocketDelegate;

@interface MHMulticastSocket : NSObject

#pragma mark - Properties

/// Delegate for the MHMultihop methods
@property (nonatomic, weak) id<MHMulticastSocketDelegate> delegate;


#pragma mark - Initialization

/**
 Init method for this class.
 
 Since you are not passing in a display name, it will default to:
 
 [UIDevice currentDevice].name]
 
 Since you are not passing a routing protocol, the default one will be 6Shots
 
 Which returns a string similar to: @"Peter's iPhone".
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType;



/**
 Init method for this class.
 
 Since you are not passing in a display name, it will default to:
 
 [UIDevice currentDevice].name]
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 
 
 @param protocol The routing protocol used.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType
                withRoutingProtocol:(MHMulticastProtocol)protocol;


/**
 Init method for this class.
 
 You must initialize this method with this method or:
 
 - (instancetype)initWithServiceType:(NSString *)serviceType;
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 
 @param displayName The display name which is sent to other peers.
 
 @param protocol The routing protocol used.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHMulticastProtocol)protocol;


/**
 Call this method to join a multicast group
 
 @param groupName The name of the group to join
 */
- (void)joinGroup:(NSString *)groupName;


/**
 Call this method to leave a multicast group
 
 @param groupName The name of the group to leave
 */
- (void)leaveGroup:(NSString *)groupName;


/**
 Call this method to disconnect from everyone. In order to restart the system, a new Multihop object
 should be reinstantiated.
 */
- (void)disconnect;


/**
 Sends a message to selected groups.
 
 They will receive the data with the delegate callback:
 
 - (void)mhMulticastSocket:(MHMulticastSocket *)mhMulticastSocket didReceiveMessage:(NSData *)data fromPeer:(NSString *)peer
 
 @param data message data to send.
 @param destinations list of multicast groups to which send the message
 @param error The address of an NSError pointer where an error object should be stored upon error.
 
 */
- (void)sendMessage:(NSData *)data
     toDestinations:(NSArray *)destinations
              error:(NSError **)error;


- (NSString *)getOwnPeer;

- (int)hopsCountFromPeer:(NSString*)peer;


// Background Mode methods
- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;

// Termination method
- (void)applicationWillTerminate;




@end

/**
 The delegate for the MHMulticastSocket class.
 */
@protocol MHMulticastSocketDelegate <NSObject>

@required
- (void)mhMulticastSocket:(MHMulticastSocket *)mhMulticastSocket
          failedToConnect:(NSError *)error;

@optional
- (void)mhMulticastSocket:(MHMulticastSocket *)mhMulticastSocket
        didReceiveMessage:(NSData *)data
                 fromPeer:(NSString *)peer
            withTraceInfo:(NSArray *)traceInfo;
@end

#endif
