//
//  MH6ShotsProtocol.h
//  Multihop
//
//  Created by quarta on 04/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MH6ShotsProtocol_h
#define Multihop_MH6ShotsProtocol_h

#import "MHRoutingProtocol.h"


@interface MH6ShotsProtocol : MHRoutingProtocol


#pragma mark - Initialization
- (instancetype)initWithPeer:(NSString *)peer withDisplayName:(NSString *)displayName;

/**
 Supported special functions ("fct name" => "arg1 name"(type), "arg2 name"(type), ...):

    Joining a group
 - join => name(NSString*)
 
    Leaving a group
 - leave => name(NSString*)
 
 */
- (void)callSpecialRoutingFunctionWithName:(NSString *)name withArgs:(NSDictionary *)args;

// Not supported
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
