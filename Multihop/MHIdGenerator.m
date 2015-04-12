//
//  MHIdGenerator.m
//  Multihop
//
//  Created by quarta on 12/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHIdGenerator.h"



@interface MHIdGenerator ()

@end

@implementation MHIdGenerator

+ (NSString *)makeUniqueStringFromSource:(NSString *)source
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMddHHmmss"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    int randomValue = arc4random() % 100000;
    
    return [NSString stringWithFormat:@"%@%@%d",dateString, source, randomValue];
}

@end