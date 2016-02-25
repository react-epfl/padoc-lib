/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHMultipeerWrapper_h
#define Padoc_MHMultipeerWrapper_h


#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MHDatagram.h"
#import "MHDiagnostics.h"
#import "MHPeer.h"

#define MH_SERVICE_PREFIX @"mh-"
#define MH_INVITATION_TIMEOUT 1000

@protocol MHMultipeerWrapperDelegate;

@interface MHMultipeerWrapper : NSObject

#pragma mark - Properties
@property (nonatomic, weak) id<MHMultipeerWrapperDelegate> delegate;
@property (nonatomic, readonly, strong) NSString *serviceType;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (void)connectToNeighbourhood;

- (void)disconnectFromNeighbourhood;

- (void)sendDatagram:(MHDatagram *)datagram
             toPeers:(NSArray *)peers
               error:(NSError **)error;

- (NSString *)getOwnPeer;

@end

@protocol MHMultipeerWrapperDelegate <NSObject>

@required
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  failedToConnect:(NSError *)error;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
didReceiveDatagram:(MHDatagram *)datagram
         fromPeer:(NSString *)peer;
@end



#endif
