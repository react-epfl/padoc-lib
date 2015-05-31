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

@protocol MHSUATPBufferDelegate;

@interface MHSUATPBuffer : NSObject

@property (nonatomic, weak) id<MHSUATPBufferDelegate> delegate;

#pragma mark - Initialization
- (instancetype)init;



- (void)pushMessage:(NSData *)data withTraceInfo:(NSarray *)traceInfo;
- (void)popMessage;


@end


/**
 The delegate for the MHSUATPBuffer class.
 */
@protocol MHSUATPBufferDelegate <NSObject>

@required
- (void)MHSUATPBuffer:(MHSUATPBuffer *)MHSUATPBuffer
           popMessage:(MHMessage *)message
        withTraceInfo:(NSArray *)traceInfo;

@end


#endif
