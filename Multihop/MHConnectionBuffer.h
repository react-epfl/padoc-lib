//
//  MHConnectionBuffer.h
//  Multihop
//
//  Created by quarta on 26/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHConnectionBuffer_h
#define Multihop_MHConnectionBuffer_h

#import <Foundation/Foundation.h>
#import "MHMultipeerWrapper.h"


#define MHCONNECTIONBUFFER_BUFFER_SIZE 1000


typedef enum MHConnectionBufferState : NSUInteger
{
    MHConnectionBufferConnected,
    MHConnectionBufferBroken
} MHConnectionBufferState;


@interface MHConnectionBuffer : NSObject

#pragma mark - Properties
@property (nonatomic, readonly, strong) NSString *peerID;
@property (nonatomic, readonly) MHConnectionBufferState status;


#pragma mark - Initialization
- (instancetype)initWithPeerID:(NSString *)peerID
          withMultipeerWrapper:(MHMultipeerWrapper *)mcWrapper;


#pragma mark - Properties
- (void)setStatus:(MHConnectionBufferState)status;

- (void)pushData:(NSData *)data;


@end

#endif
