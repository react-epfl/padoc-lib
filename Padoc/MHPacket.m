/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MHPacket.h"



@interface MHPacket ()

@property (nonatomic, readwrite, strong) NSString *tag;
@property (nonatomic, readwrite, strong) NSString *source;
@property (nonatomic, readwrite, strong) NSArray *destinations;
@property (nonatomic, readwrite, strong) NSData *data;

@property (nonatomic, readwrite, strong) NSMutableDictionary *info;

@end

@implementation MHPacket

- (instancetype)initWithSource:(NSString *)source
              withDestinations:(NSArray *)destinations
                      withData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        // Generate new packet id
        self.tag = [MHComputation makeUniqueStringFromSource:source];
        self.source = source;
        self.destinations = destinations;
        self.data = data;
        
        self.info = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.tag = [decoder decodeObjectForKey:@"tag"];
        self.source = [decoder decodeObjectForKey:@"source"];
        self.destinations = [decoder decodeObjectForKey:@"destinations"];
        self.data = [decoder decodeObjectForKey:@"data"];
        self.info = [decoder decodeObjectForKey:@"info"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.tag forKey:@"tag"];
    [encoder encodeObject:self.source forKey:@"source"];
    [encoder encodeObject:self.destinations forKey:@"destinations"];
    [encoder encodeObject:self.data forKey:@"data"];
    [encoder encodeObject:self.info forKey:@"info"];
}


- (void)dealloc
{
    [self.info removeAllObjects];
    self.info = nil;
    self.destinations = nil;
    self.data = nil;
    self.tag = nil;
    self.source = nil;
}


- (NSData *)asNSData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    return data;
}


+ (MHPacket *)fromNSData:(NSData *)nsData
{
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:nsData];

    if([object isKindOfClass:[MHPacket class]])
    {
        MHPacket *packet = object;
        
        return packet;
    }
    else
    {
        return nil;
    }
}

@end