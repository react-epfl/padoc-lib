/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef consoleViewer_MHConnectionsHandler_h
#define consoleViewer_MHConnectionsHandler_h


#import <Foundation/Foundation.h>
#import "MHMultipeerWrapper.h"
#import "MHConnectionBuffer.h"
#import "MHDatagram.h"


#define MHCONNECTIONSHANDLER_BACKGROUND_SIGNAL @"[{_-background_sgn-_}]"
#define MHCONNECTIONSHANDLER_CHECK_TIME 60

/**
 
 This layer has 2 purposes:
 - Limit the outgoing trafic throughput, so that the
 low level API does not get saturated (and errors occur).
 
 - Hide to the above layers the disconnection/reconnection process
 that randomly occur between peers (for example, when switching background tasks).
 Messages sent during that short period are buffered and sent later.
 
 **/


@protocol MHConnectionsHandlerDelegate;

@interface MHConnectionsHandler : NSObject

#pragma mark - Properties
@property (nonatomic, weak) id<MHConnectionsHandlerDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (void)connectToNeighbourhood;

- (void)disconnectFromNeighbourhood;


- (void)sendDatagram:(MHDatagram *)datagram
             toPeers:(NSArray *)peers
               error:(NSError **)error;

- (NSString *)getOwnPeer;

#pragma mark - Background handling
- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;

@end

@protocol MHConnectionsHandlerDelegate <NSObject>

@required
- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName;

- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer;

- (void)cHandler:(MHConnectionsHandler *)cHandler
 failedToConnect:(NSError *)error;

- (void)cHandler:(MHConnectionsHandler *)cHandler
didReceiveDatagram:(MHDatagram *)datagram
        fromPeer:(NSString *)peer;

- (void)cHandler:(MHConnectionsHandler *)cHandler
  enteredStandby:(NSString *)info
            peer:(NSString *)peer;

- (void)cHandler:(MHConnectionsHandler *)cHandler
   leavedStandby:(NSString *)info
            peer:(NSString *)peer;
@end



#endif
