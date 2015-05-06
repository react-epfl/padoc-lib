//
//  MHUnicastSocket.h
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHUnicastSocket_h
#define Multihop_MHUnicastSocket_h

#import <Foundation/Foundation.h>
#import "MHUnicastController.h"



@protocol MHUnicastSocketDelegate;

@interface MHUnicastSocket : NSObject

#pragma mark - Properties

/// Delegate for the MHMultihop methods
@property (nonatomic, weak) id<MHUnicastSocketDelegate> delegate;


#pragma mark - Initialization

/**
 Init method for this class.
 
 Since you are not passing in a display name, it will default to:
 
 [UIDevice currentDevice].name]
 
 Since you are not passing a routing protocol, the default one will be Flooding
 
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
                withRoutingProtocol:(MHUnicastProtocol)protocol;


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
                withRoutingProtocol:(MHUnicastProtocol)protocol;



/**
 Call this method to disconnect from the neighbourhood. In order to restart the system, a new Multihop object
 should be reinstantiated.
 */
- (void)disconnect;


/**
 Sends a message to selected peers.
 
 They will receive the data with the delegate callback:
 
 - (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket didReceivePacket:(MHPacket *)packet

 @param data message data to send.
 @param destinations list of peers to which send the message
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
 The delegate for the MHUnicastSocket class.
 */
@protocol MHUnicastSocketDelegate <NSObject>

@required
- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
           isDiscovered:(NSString *)info
                   peer:(NSString *)peer
            displayName:(NSString *)displayName;

@required
- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
        hasDisconnected:(NSString *)info
                   peer:(NSString *)peer;

- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
        failedToConnect:(NSError *)error;

@optional
- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
      didReceiveMessage:(NSData *)data
               fromPeer:(NSString *)peer
          withTraceInfo:(NSArray *)traceInfo;
@end


#endif
