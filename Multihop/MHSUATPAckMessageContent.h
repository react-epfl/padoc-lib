//
//  MHSUATPAckMessageContent.h
//  Multihop
//
//  Created by quarta on 01/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHSUATPAckMessageContent_h
#define Multihop_MHSUATPAckMessageContent_h

#import <Foundation/Foundation.h>

@interface MHSUATPAckMessageContent : NSObject<NSCoding>

@property (nonatomic, readonly, strong) NSArray *missingMessages;
@property (nonatomic, readonly) NSUInteger lastReceivedMessage;


- (instancetype)initWithMissingMessages:(NSArray *)missingMessages
                     withLastRcvMessage:(NSUInteger)lastRcvMessage;

@end

#endif
