//
//  MHUnicastRoutingProtocol.h
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHUnicastRoutingProtocol_h
#define Multihop_MHUnicastRoutingProtocol_h


#import <Foundation/Foundation.h>
#import "MHConnectionsHandler.h"
#import "MHPacket.h"

// Diagnostics
#import "MHDiagnostics.h"


@protocol MHUnicastRoutingProtocolDelegate;

@interface MHUnicastRoutingProtocol : NSObject

#pragma mark - Properties

@property (nonatomic, weak) id<MHUnicastRoutingProtocolDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (NSString *)getOwnPeer;


- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;


#pragma mark - Overridable methods
- (void)disconnect;

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;

- (int)hopsCountFromPeer:(NSString*)peer;

@end


@protocol MHUnicastRoutingProtocolDelegate <NSObject>

@required
- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName;

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   hasDisconnected:(NSString *)info
              peer:(NSString *)peer;

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error;

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
     withTraceInfo:(NSArray *)traceInfo;
@end


#endif
