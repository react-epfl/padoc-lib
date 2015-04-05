//
//  MHFloodingProtocol.h
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHFloodingProtocol_h
#define Multihop_MHFloodingProtocol_h

#import "MHUnicastRoutingProtocol.h"


@interface MHFloodingProtocol : MHUnicastRoutingProtocol


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;


- (void)disconnect;

- (void)discover;


- (void)sendPacket:(MHPacket *)packet
             error:(NSError **)error;


@end

#endif
