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
#define MHPEERBUFFER_RELEASE_DELAY 100


@interface MHPeerBuffer : NSObject




#pragma mark - Initialization
- (instancetype)initWithMCSession:(MCSession *)session;


- (void)pushDatagram:(MHDatagram *)datagram;

// release delay??
- (void)setConnected;
- (void)setDisconnected;

@end


#endif
