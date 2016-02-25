/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MHConfig.h"


@interface MHConfig ()


@end


#pragma mark - Singleton static variables

static MHConfig *params = nil;



@implementation MHConfig

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        [self setDefaults];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)setDefaults
{
    // Link layer
    self.linkHeartbeatSendDelay = 2000;
    self.linkMaxHeartbeatFails = 4;
    
    self.linkDatagramSendDelay = 250;
    self.linkMaxDatagramSize = 3000;
    
    self.linkBackgroundDatagramSendDelay = 20;
    
    
    // Network layer
    self.netPacketTTL = 100;
    self.netProcessedPacketsCleaningDelay = 30000;
    
    self.netCBSPacketForwardDelayRange = 100;
    self.netCBSPacketForwardDelayBase = 30;
    
    self.net6ShotsControlPacketForwardDelayRange = 50;
    self.net6ShotsControlPacketForwardDelayBase = 20;
    
    self.net6ShotsPacketForwardDelayRange = 100;
    self.net6ShotsPacketForwardDelayBase = 30;
    
    self.net6ShotsOverlayMaintenanceDelay = 5000;
    
    self.netDeviceTransmissionRange = 40;
}

#pragma mark - Singleton methods
+ (MHConfig*)getSingleton
{
    if (params == nil)
    {
        // Initialize the parameters singleton
        params = [[MHConfig alloc] init];
    }
    
    return params;
}

@end