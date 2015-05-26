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
#import "MHMessage.h"


typedef enum MHMulticastProtocol
{
    MHMulticast6ShotsProtocol
}MHMulticastProtocol;

@protocol MHMulticastControllerDelegate;

@interface MHMulticastController : NSObject

#pragma mark - Properties


@property (nonatomic, weak) id<MHMulticastControllerDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHMulticastProtocol)protocol;

- (void)joinGroup:(NSString *)groupName;

- (void)leaveGroup:(NSString *)groupName;


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
@protocol MHMulticastControllerDelegate <NSObject>

@required
- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
                  joinedGroup:(NSString *)info
                         peer:(NSString *)peer
                        group:(NSString *)group;

- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
          failedToConnect:(NSError *)error;

- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
        didReceiveMessage:(NSData *)data
                 fromPeer:(NSString *)peer
            withTraceInfo:(NSArray *)traceInfo;
@end


#endif
