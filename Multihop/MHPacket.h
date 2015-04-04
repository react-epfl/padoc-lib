//
//  MHPacket.h
//  Multihop
//
//  Created by quarta on 03/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHPacket_h
#define Multihop_MHPacket_h


#import <Foundation/Foundation.h>


@interface MHPacket : NSObject<NSCoding>

@property (nonatomic, readonly, strong) NSString *tag;
@property (nonatomic, readonly, strong) NSString *source;
@property (nonatomic, readonly, strong) NSArray *destinations;
@property (nonatomic, readonly, strong) NSData *data;

@property (nonatomic, readonly, strong) NSMutableDictionary *info;


- (instancetype)initWithSource:(NSString *)source
               withDestinations:(NSArray *)destinations
                      withData:(NSData *)data;

- (NSData *)asNSData;


+ (MHPacket *)fromNSData:(NSData *)nsData;

+ (NSString *)makeUniqueStringFromPeer:(NSString *)peer;

@end


#endif
