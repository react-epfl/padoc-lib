//
//  MHSocket.h
//  Multihop
//
//  Created by quarta on 02/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHSocket_h
#define Multihop_MHSocket_h


#import <Foundation/Foundation.h>
#import "MHController.h"


@protocol MHSocketDelegate;

@interface MHSocket : NSObject

#pragma mark - Properties

/// Delegate for the MHMultihop methods
@property (nonatomic, weak) id<MHSocketDelegate> delegate;


#pragma mark - Initialization


- (instancetype)initWithServiceType:(NSString *)serviceType;

- (instancetype)initWithServiceType:(NSString *)serviceType
                withRoutingProtocol:(MHRoutingProtocols)protocol;

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol;


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

/**
 Return the current peer id
 */
- (NSString *)getOwnPeer;

/**
 Returns the number of hops from a particular peer
 
 @param peer the peer id
 */
- (int)hopsCountFromPeer:(NSString*)peer;


// Background Mode methods
- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;

// Termination method
- (void)applicationWillTerminate;




@end

/**
 The delegate for the MHSocket class.
 */
@protocol MHSocketDelegate <NSObject>

@required
- (void)mhSocket:(MHSocket *)mhSocket
 failedToConnect:(NSError *)error;

@optional
- (void)mhSocket:(MHSocket *)mhSocket
didReceiveMessage:(NSData *)data
        fromPeer:(NSString *)peer
   withTraceInfo:(NSArray *)traceInfo;

#pragma mark - Diagnostics info callbacks
- (void)mhSocket:(MHSocket *)mhSocket
   forwardPacket:(NSString *)info
      fromSource:(NSString *)peer;
@end

#endif
