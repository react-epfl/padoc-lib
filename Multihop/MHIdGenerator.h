//
//  MHIdGenerator.h
//  Multihop
//
//  Created by quarta on 12/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHIdGenerator_h
#define Multihop_MHIdGenerator_h

#import <Foundation/Foundation.h>


@interface MHIdGenerator : NSObject

+ (NSString *)makeUniqueStringFromSource:(NSString *)source;

@end


#endif
