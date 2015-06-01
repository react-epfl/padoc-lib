//
//  MHSUATPBuffer.m
//  Multihop
//
//  Created by quarta on 31/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHSUATPBuffer.h"



@interface MHSUATPBuffer ()

@property (nonatomic, strong) NSMutableDictionary *messages;

@property (nonatomic) NSInteger last;

@end

@implementation MHSUATPBuffer

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.messages = [[NSMutableDictionary alloc] init];
        self.last = -1;
    }
    return self;
}

- (void)dealloc
{
    [self.messages removeAllObjects];
    self.messages = nil;
}


- (BOOL)isEmpty
{
    // Concurrency problems???
    return self.last == -1;
}

- (void)pushMessage:(MHMessage *)message withTraceInfo:(NSArray *)traceInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.last == -1)
        {
            self.last = message.seqNumber;
        }
        else if(message.seqNumber > self.last)
        {
            self.last = message.seqNumber;
        }
        
        [self.messages setObject:[[MHSUATPBufferMessage alloc] initWithMessage:message
                                                                 withTraceInfo:traceInfo]
                          forKey:[NSNumber numberWithUnsignedInteger:message.seqNumber]];
    });
}

- (MHSUATPBufferMessage *)popMessage
{
    if (self.messages.count > 0)
    {
        NSNumber *min=[[self.messages allKeys] valueForKeyPath:@"@min.self"];
        
        MHSUATPBufferMessage *msg = [self.messages objectForKey:min];
        [self.messages removeObjectForKey:min];
        
        
        if (self.messages.count == 0)
        {
            self.last = -1;
        }
        
        return msg;
    }
    else
    {
        return nil;
    }
}


#pragma mark - Control methods
- (void)clearUntil:(NSUInteger)seqNumber
{
    NSArray *sortedKeys = [[self.messages allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (id msgKey in sortedKeys)
    {
        NSUInteger msgNo = [((NSNumber *)msgKey) unsignedIntegerValue];
        
        
        if (msgNo <= seqNumber)
        {
            [self.messages removeObjectForKey:msgKey];
        }
        else
        {
            break;
        }
    }
}

- (NSUInteger)lastElement
{
    return self.last;
}

@end
