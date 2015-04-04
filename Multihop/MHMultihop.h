//
//  MHMultihop.h
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHMultihop_h
#define Multihop_MHMultihop_h

#import <Foundation/Foundation.h>
#import "MHRouter.h"
#import "MHPacket.h"


@protocol MHMultihopDelegate;

@interface MHMultihop : NSObject

#pragma mark - Properties

/// Delegate for the MHMultihop methods
@property (nonatomic, weak) id<MHMultihopDelegate> delegate;


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
                withRoutingProtocol:(MHProtocol)protocol;


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
                withRoutingProtocol:(MHProtocol)protocol;


/**
 Call this method to connect to all peers. It will automatically start searching for peers.
 Note that the method is not supported by all routing algorithms. In case it is not supported,
 nothing happens.
 
 When you successfully connect to another peer, you will receive a delegate callback to:
 
 - (void)mhHandler:(MHMultihop *)mhHandler isDiscovered:(NSString *)info peer:(NSString *)peer displayName:(NSString *)displayName
 */
- (void)discover;


/**
 Call this method to disconnect from everyone. In order to restart the system, a new Multihop object
 should be reinstantiated.
 */
- (void)disconnect;


/**
 Sends a packet to selected peers.
 
 They will receive the data with the delegate callback:
 
 - (void)mhHandler:(MHMultihop *)mhHandler didReceivePacket:(MHPacket *)packet
 
 @param packet packet to send.
 @param error The address of an NSError pointer where an error object should be stored upon error.
 
 */
- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;


- (NSString *)getOwnPeer;


/**
 This methods enables the user to call a special function of the specified routing algorithm.
 This mechanism is available due to the highly heterogenity of provided functions by different
 routing algorithms. Every algorithm provides a documentation descriving the supported functions
 
 @param name Name of the special function
 @param args Dictionary containing a list of arguments taken by the special function.
             Note that the name of an argument is defined by the dictionary key.
 */
- (void)callSpecialRoutingFunctionWithName:(NSString *)name withArgs:(NSDictionary *)args;


// Background Mode methods
- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;

// Termination method
- (void)applicationWillTerminate;




@end

/**
 The delegate for the MHMultihop class.
 */
@protocol MHMultihopDelegate <NSObject>

@required
- (void)mhHandler:(MHMultihop *)mhHandler
     isDiscovered:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName;

@required
- (void)mhHandler:(MHMultihop *)mhHandler
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer;

- (void)mhHandler:(MHMultihop *)mhHandler
  failedToConnect:(NSError *)error;

@optional
- (void)mhHandler:(MHMultihop *)mhHandler
 didReceivePacket:(MHPacket *)packet;
@end


#endif
