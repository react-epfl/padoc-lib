/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MHComputation.h"



@interface MHComputation ()

@end

@implementation MHComputation

+ (NSString *)makeUniqueStringFromSource:(NSString *)source
{
    // Generate string based on datetime
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMddHHmmss"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    // Generate random value
    int randomValue = arc4random() % 100000;
    
    
    // Generate final string of the form: [date][source][random value]
    return [NSString stringWithFormat:@"%@%@%d",dateString, source, randomValue];
}

# pragma mark - Math helper methods
+ (double)sign:(double)value
{
    if (value >= 0)
    {
        return 1.0;
    }
    
    return -1.0;
}

+ (double)toRad:(double)deg
{
    return deg * M_PI / 180.0;
}

#pragma mark - Data helper methods
+ (NSData*)emptyData
{
    return [@"" dataUsingEncoding:NSUTF8StringEncoding];
}

@end