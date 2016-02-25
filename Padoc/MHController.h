/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHController_h
#define Padoc_MHController_h


#import <Foundation/Foundation.h>
#import "MHRoutingProtocol.h"
#import "MHMessage.h"

// Protocols
#import "MH6ShotsProtocol.h"
#import "MHFloodingProtocol.h"
#import "MHCBSProtocol.h"


typedef enum MHRoutingProtocols
{
    MH6ShotsRoutingProtocol,
    MHCBSRoutingProtocol,
    MHFloodingRoutingProtocol
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

- (void)joinGroup:(NSString *)groupName
          maxHops:(int)maxHops;

- (void)leaveGroup:(NSString *)groupName
           maxHops:(int)maxHops;

- (void)sendMessage:(MHMessage *)message
     toDestinations:(NSArray *)destinations
            maxHops:(int)maxHops
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
   didReceiveMessage:(MHMessage *)message
          fromGroups:(NSArray *)groups
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

- (void)mhController:(MHController *)mhController
         joinedGroup:(NSString *)info
                peer:(NSString *)peer
         displayName:(NSString *)displayName
               group:(NSString *)group;
@end


#endif
