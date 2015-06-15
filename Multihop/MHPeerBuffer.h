//
//  MHPeerBuffer.h
//  Multihop
//
//  Created by quarta on 13/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHPeerBuffer_h
#define Multihop_MHPeerBuffer_h

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MHDatagram.h"


#define MHPEERBUFFER_BUFFER_SIZE 1000
#define MHPEERBUFFER_RELEASE_DELAY 10
#define MHPEERBUFFER_MAX_CHUNK_SIZE 10000


@protocol MHPeerBufferDelegate;

@interface MHPeerBuffer : NSObject

@property(nonatomic, weak) id<MHPeerBufferDelegate> delegate;

#pragma mark - Initialization
- (instancetype)initWithMCSession:(MCSession *)session;


- (void)pushDatagram:(MHDatagram *)datagram;

// release delay??
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