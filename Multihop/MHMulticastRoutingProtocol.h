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
#import "MHRoutingProtocol.h"


@protocol MHMulticastRoutingProtocolDelegate;

@interface MHMulticastRoutingProtocol : MHRoutingProtocol

#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;



#pragma mark - Overridable methods
- (void)disconnect;

- (void)joinGroup:(NSString *)groupName;

- (void)leaveGroup:(NSString *)groupName;

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;

- (int)hopsCountFromPeer:(NSString*)peer;

@end


@protocol MHMulticastRoutingProtocolDelegate <MHRoutingProtocolDelegate>

@required
#pragma mark - Diagnostics info callbacks
- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
       joinedGroup:(NSString *)info
              peer:(NSString *)peer
             group:(NSString *)group;
@end

#endif
