//
//  MHMessage.h
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHMessage_h
#define Multihop_MHMessage_h

#import <Foundation/Foundation.h>

@interface MHMessage : NSObject<NSCoding>

@property (nonatomic, readonly, strong) NSData *data;

// other info...

- (instancetype)initWithData:(NSData *)data;

- (NSData *)asNSData;


+ (MHMessage *)fromNSData:(NSData *)nsData;
@end


#endif
