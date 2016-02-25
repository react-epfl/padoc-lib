/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MHMessage.h"

@interface MHMessage ()

@property (nonatomic, readwrite, strong) NSData *data;

@end

@implementation MHMessage

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        self.data = data;
        self.sin = NO;
        self.ack = NO;
        self.seqNumber = 0;
        self.ackNumber = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.data = [decoder decodeObjectForKey:@"data"];
        self.seqNumber = [decoder decodeIntegerForKey:@"seqNumber"];
        self.ackNumber = [decoder decodeIntegerForKey:@"ackNumber"];
        self.sin = [decoder decodeBoolForKey:@"sin"];
        self.ack = [decoder decodeBoolForKey:@"ack"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.data forKey:@"data"];
    [encoder encodeInteger:self.seqNumber forKey:@"seqNumber"];
    [encoder encodeInteger:self.ackNumber forKey:@"ackNumber"];
    [encoder encodeBool:self.sin forKey:@"sin"];
    [encoder encodeBool:self.ack forKey:@"ack"];
}


- (void)dealloc
{
    self.data = nil;
}


- (NSData *)asNSData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    return data;
}


+ (MHMessage *)fromNSData:(NSData *)nsData
{
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:nsData];
    
    if([object isKindOfClass:[MHMessage class]])
    {
        MHMessage *message = object;
        
        return message;
    }
    else
    {
        return nil;
    }
}

@end
