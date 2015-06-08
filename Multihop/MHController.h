//
//  MHController.h
//  Multihop
//
//  Created by quarta on 02/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHController_h
#define Multihop_MHController_h


#import <Foundation/Foundation.h>
#import "MHRoutingProtocol.h"
#import "MHMessage.h"


typedef enum MHRoutingProtocols
{
    MHMulticast6ShotsProtocol,
    MHUnicastFloodingProtocol
}MHRoutingProtocols;

@protocol MHControllerDelegate;

@interface MHController : NSObject

#pragma mark - Properties


@property (nonatomic, weak) id<MHControllerDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol;


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
 The delegate for the MHMulticastController class.
 */
@protocol MHControllerDelegate <NSObject>

@required
- (void)mhController:(MHController *)mhController
     failedToConnect:(NSError *)error;

- (void)mhController:(MHController *)mhController
   didReceiveMessage:(NSData *)data
            fromPeer:(NSString *)peer
       withTraceInfo:(NSArray *)traceInfo;

#pragma mark - Diagnostics info callbacks
- (void)mhController:(MHController *)mhController
       forwardPacket:(NSString *)info
         withMessage:(MHMessage *)message
          fromSource:(NSString *)peer;

- (void)mhController:(MHController *)mhController
neighbourConnected:(NSString *)info
                peer:(NSString *)peer
         displayName:(NSString *)displayName;

- (void)mhController:(MHController *)mhController
neighbourDisconnected:(NSString *)info
                peer:(NSString *)peer;
@end


#endif
