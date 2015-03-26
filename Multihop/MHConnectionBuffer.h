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

@interface MHConnectionBuffer : NSObject

#pragma mark - Properties
@property (nonatomic, readonly, strong) NSString *peerID;
@property (nonatomic, readonly) NSUInteger status;


#pragma mark - Initialization
- (instancetype)initWithPeerID:(NSString *)peerID;


#pragma mark - Properties
- (void)setStatus:(NSUInteger)status;

- (void)pushData:(NSData *)data;
- (NSData *)popData;


@end

typedef enum MHConnectionBufferState : NSUInteger
{
    MHConnectionBufferDisconnected,
    MHConnectionBufferConnected,
    MHConnectionBufferBroken
} MHConnectionBufferState;

#endif
