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

#define MH_FLOODING_TTL 10
#define MH_FLOODING_DISCOVERME_MSG @"-[discoverme-msg]-"

#define MH_FLOODING_SCHEDULECLEANING_DELAY 10000

@interface MHFloodingProtocol : MHRoutingProtocol


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;


- (void)disconnect;

- (void)joinGroup:(NSString *)groupName;

- (void)leaveGroup:(NSString *)groupName;

- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;


@end

#endif
