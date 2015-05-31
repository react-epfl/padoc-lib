//
//  MHSUATPBuffer.m
//  Multihop
//
//  Created by quarta on 31/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHSUATPBuffer.h"



@interface MHSUATPBuffer ()

@property (nonatomic, strong) NSMutableDictionary *bufferMessages;

@end

@implementation MHSUATPBuffer

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.bufferMessages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.bufferMessages removeAllObjects];
    self.bufferMessages = nil;
}

- (void)pushMessage:(NSData *)data withTraceInfo:(id)traceInfo
{
    [self.bufferMessages setObject:nil forKey:[[NSNumber alloc] initWithInt:100]];
}

- (void)popMessage
{
    
}

@end
