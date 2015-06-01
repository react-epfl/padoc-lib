//
//  MHSUATPBuffer.h
//  Multihop
//
//  Created by quarta on 31/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHSUATPBuffer_h
#define Multihop_MHSUATPBuffer_h

#import <Foundation/Foundation.h>
#import "MHMessage.h"
#import "MHSUATPBufferMessage.h"

#define MHCONNECTIONBUFFER_BUFFER_SIZE 1000


@interface MHSUATPBuffer : NSObject


#pragma mark - Initialization
- (instancetype)init;



- (void)pushMessage:(MHMessage *)message withTraceInfo:(NSArray *)traceInfo;
- (MHSUATPBufferMessage *)popMessage; // Must be called from an async task running on the main thread!!!

- (BOOL)isEmpty;

#pragma mark - Control methods
- (void)clearUntil:(NSUInteger)seqNumber;
- (NSUInteger)lastElement;

@end


#endif
