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
#import "MHMessage.h"

#import "MHUnicastConnection.h"


typedef enum MHUnicastProtocol
{
    MHUnicastFloodingProtocol
}MHUnicastProtocol;

@protocol MHUnicastControllerDelegate;

@interface MHUnicastController : NSObject

#pragma mark - Properties


@property (nonatomic, weak) id<MHUnicastControllerDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHUnicastProtocol)protocol;



- (void)disconnect;


- (void)sendMessage:(MHMessage *)message
     toDestinations:(NSArray *)destinations
              error:(NSError **)error;


- (NSString *)getOwnPeer;

- (int)hopsCountFromPeer:(NSString*)peer;


// Background Mode methods
- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;

// Termination method
- (void)applicationWillTerminate;




@end

/**
 The delegate for the MHUnicastController class.
 */
@protocol MHUnicastControllerDelegate <NSObject>

@required
- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
               isDiscovered:(NSString *)info
                       peer:(NSString *)peer
                displayName:(NSString *)displayName;

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
            hasDisconnected:(NSString *)info
                       peer:(NSString *)peer;

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
            failedToConnect:(NSError *)error;

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
          didReceiveMessage:(MHMessage *)message
                   fromPeer:(NSString *)peer
              withTraceInfo:(NSArray *)traceInfo;
@end


#endif
