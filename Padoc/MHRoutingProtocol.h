/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHRoutingProtocol_h
#define Padoc_MHRoutingProtocol_h


#import <Foundation/Foundation.h>
#import "MHConnectionsHandler.h"
#import "MHPacket.h"
#import "MHDatagram.h"

#import "MHConfig.h"

// Diagnostics
#import "MHDiagnostics.h"



@protocol MHRoutingProtocolDelegate;

@interface MHRoutingProtocol : NSObject

#pragma mark - Properties

@property(nonatomic, weak) id<MHRoutingProtocolDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (NSString *)getOwnPeer;


- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;


#pragma mark - Overridable methods
- (void)disconnect;

- (void)joinGroup:(NSString *)groupName
          maxHops:(int)maxHops;

- (void)leaveGroup:(NSString *)groupName
           maxHops:(int)maxHops;

- (void)sendPacket:(MHPacket *)packet
           maxHops:(int)maxHops
             error:(NSError **)error;

- (int)hopsCountFromPeer:(NSString*)peer;

@end


@protocol MHRoutingProtocolDelegate <NSObject>

@required
- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
   failedToConnect:(NSError *)error;

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
  didReceivePacket:(MHPacket *)packet
        fromGroups:(NSArray *)groups
     withTraceInfo:(NSArray *)traceInfo;


#pragma mark - Diagnostics info callbacks
- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
     forwardPacket:(NSString *)info
        withPacket:(MHPacket *)packet;

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
neighbourConnected:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName;

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
neighbourDisconnected:(NSString *)info
              peer:(NSString *)peer;

- (void)mhProtocol:(MHRoutingProtocol *)mhProtocol
       joinedGroup:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName
             group:(NSString *)group;
@end


#endif
