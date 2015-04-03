//
//  MHFloodingProtocol.h
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHFloodingProtocol_h
#define Multihop_MHFloodingProtocol_h


#import "MHRoutingProtocol.h"


@interface MHFloodingProtocol : MHRoutingProtocol


#pragma mark - Initialization
- (instancetype)initWithPeer:(NSString *)peer withDisplayName:(NSString *)displayName;


- (void)discover;

- (void)disconnect;

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;




#pragma mark - ConnectionsHandler methods
- (void)hasConnected:(NSString *)info
                peer:(NSString *)peer
         displayName:(NSString *)displayName;

- (void)hasDisconnected:(NSString *)info
                   peer:(NSString *)peer;


- (void)didReceivePacket:(MHPacket *)packet
                fromPeer:(NSString *)peer;

- (void)enteredStandby:(NSString *)info
                  peer:(NSString *)peer;

- (void)leavedStandby:(NSString *)info
                 peer:(NSString *)peer;

@end

#endif
