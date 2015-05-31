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

@property (nonatomic, strong) NSString *name;

@property (nonatomic) NSInteger last;

@end

@implementation MHSUATPBuffer

#pragma mark - Life Cycle

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        self.messages = [[NSMutableDictionary alloc] init];
        self.name = name;
        self.last = -1;
    }
    return self;
}

- (void)dealloc
{
    [self.messages removeAllObjects];
    self.messages = nil;
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

- (void)popMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.messages.count > 0)
        {
            NSNumber *min=[[self.messages allKeys] valueForKeyPath:@"@min.self"];
            
            MHSUATPBufferMessage *msg = [self.messages objectForKey:min];
            [self.messages removeObjectForKey:min];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate mhSUATPBuffer:self
                                        name:self.name
                                  popMessage:msg.message
                               withTraceInfo:msg.traceInfo];
            });
            
            if (self.messages.count == 0)
            {
                self.last = -1;
            }
        }
    });
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
        
        if(msgNo == seqNumber)
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
