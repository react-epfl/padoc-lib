//
//  MHMulticastController.h
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHMulticastController_h
#define Multihop_MHMulticastController_h


#import <Foundation/Foundation.h>
#import "MH6ShotsProtocol.h"
#import "MHMulticastRoutingProtocol.h"
#import "MHController.h"



@protocol MHMulticastControllerDelegate;

@interface MHMulticastController : MHController


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol;

- (void)joinGroup:(NSString *)groupName;

- (void)leaveGroup:(NSString *)groupName;



@end

/**
 The delegate for the MHMulticastController class.
 */
@protocol MHMulticastControllerDelegate <MHControllerDelegate>

@required
#pragma mark - Diagnostics info callbacks
- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
                  joinedGroup:(NSString *)info
                         peer:(NSString *)peer
                        group:(NSString *)group;
@end


#endif
