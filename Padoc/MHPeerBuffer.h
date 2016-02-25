/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHPeerBuffer_h
#define Padoc_MHPeerBuffer_h

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MHDatagram.h"

#import "MHConfig.h"

#define MHPEERBUFFER_BUFFER_SIZE 1000

#define MHPEERBUFFER_DECREASE_AMOUNT 50
#define MHPEERBUFFER_LOWEST_DELAY 10

@protocol MHPeerBufferDelegate;

@interface MHPeerBuffer : NSObject

@property(nonatomic, weak) id<MHPeerBufferDelegate> delegate;

#pragma mark - Initialization
- (instancetype)initWithMCSession:(MCSession *)session;


- (void)pushDatagram:(MHDatagram *)datagram;


- (void)setDelayTo:(NSInteger)delay;

- (void)setConnected;
- (void)setDisconnected;

- (void)didReceiveDatagramChunk:(MHDatagram *)chunk;

@end



@protocol MHPeerBufferDelegate <NSObject>

@required
- (void)mhPeerBuffer:(MHPeerBuffer *)mhPeerBuffer
  didReceiveDatagram:(MHDatagram *)datagram;

@end



#endif
