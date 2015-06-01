//
//  MHSUATPAckMessageContent.m
//  Multihop
//
//  Created by quarta on 01/06/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHSUATPAckMessageContent.h"

@interface MHSUATPAckMessageContent ()

@property (nonatomic, readwrite, strong) NSArray *missingMessages;
@property (nonatomic, readwrite) NSUInteger lastReceivedMessage;

@end

@implementation MHSUATPAckMessageContent

- (instancetype)initWithMissingMessages:(NSArray *)missingMessages withLastRcvMessage:(NSUInteger)lastRcvMessage
{
    self = [super init];
    if (self)
    {
        self.missingMessages = missingMessages;
        self.lastReceivedMessage = lastRcvMessage;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.missingMessages = [decoder decodeObjectForKey:@"missingMessages"];
        self.lastReceivedMessage = [decoder decodeIntegerForKey:@"lastReceivedNumber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.missingMessages forKey:@"missingMessages"];
    [encoder encodeInteger:self.lastReceivedMessage forKey:@"lastReceivedNumber"];
}


- (void)dealloc
{
    self.missingMessages = nil;
}


@end
