//
//  MHMulticastRoutingProtocol.h
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHMulticastRoutingProtocol_h
#define Multihop_MHMulticastRoutingProtocol_h


#import <Foundation/Foundation.h>
#import "MHConnectionsHandler.h"
#import "MHPacket.h"

// Diagnostics
#import "MHDiagnostics.h"



@protocol MHMulticastRoutingProtocolDelegate;

@interface MHMulticastRoutingProtocol : NSObject

#pragma mark - Properties

@property (nonatomic, weak) id<MHMulticastRoutingProtocolDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (NSString *)getOwnPeer;


- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;


#pragma mark - Overridable methods
- (void)disconnect;

- (void)joinGroup:(NSString *)groupName;

- (void)leaveGroup:(NSString *)groupName;

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;

- (int)hopsCountFromPeer:(NSString*)peer;

@end


@protocol MHMulticastRoutingProtocolDelegate <NSObject>

@required
- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error;

- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
     withTraceInfo:(NSArray *)traceInfo;
@end

#endif
