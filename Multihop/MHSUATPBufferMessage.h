//
//  MHSUATPBufferMessage.h
//  Multihop
//
//  Created by quarta on 31/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHSUATPBufferMessage_h
#define Multihop_MHSUATPBufferMessage_h

#import <Foundation/Foundation.h>
#import "MHMessage.h"

@interface MHSUATPBufferMessage : NSObject

@property (nonatomic, readwrite) MHMessage *message;
@property (nonatomic, readwrite) NSArray *traceInfo;
@property (nonatomic, readwrite) NSUInteger priority;



- (instancetype)initWithMessage:(MHMessage *)message
                  withTraceInfo:(NSArray *)traceInfo
                   withPriority:(NSUInteger)priority;

@end


#endif
