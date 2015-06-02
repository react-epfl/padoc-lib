//
//  MHUnicastController.h
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHUnicastController_h
#define Multihop_MHUnicastController_h


#import <Foundation/Foundation.h>
#import "MHFloodingProtocol.h"
#import "MHUnicastRoutingProtocol.h"
#import "MHController.h"


@protocol MHUnicastControllerDelegate;

@interface MHUnicastController : MHController



#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol;


@end

/**
 The delegate for the MHUnicastController class.
 */
@protocol MHUnicastControllerDelegate <MHControllerDelegate>

@required
- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
               isDiscovered:(NSString *)info
                       peer:(NSString *)peer
                displayName:(NSString *)displayName;

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
            hasDisconnected:(NSString *)info
                       peer:(NSString *)peer;
@end


#endif
