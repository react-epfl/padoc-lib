/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHParameters_h
#define Padoc_MHParameters_h

#import <Foundation/Foundation.h>


@interface MHConfig : NSObject

#pragma mark - Link layer
@property (nonatomic, readwrite) int linkHeartbeatSendDelay; // in milliseconds (default 2000)
@property (nonatomic, readwrite) int linkMaxHeartbeatFails; // default 5

@property (nonatomic, readwrite) int linkDatagramSendDelay; // in ms (default 250)
@property (nonatomic, readwrite) int linkMaxDatagramSize; // default 3000

@property (nonatomic, readwrite) int linkBackgroundDatagramSendDelay; // in ms (default 20)


#pragma mark - Network layer
@property (nonatomic, readwrite) int netPacketTTL; // default 100
@property (nonatomic, readwrite) int netProcessedPacketsCleaningDelay; // in ms (default 30000)

@property (nonatomic, readwrite) int netCBSPacketForwardDelayRange; // in ms (default 100)
@property (nonatomic, readwrite) int netCBSPacketForwardDelayBase; // in ms (default 30)

@property (nonatomic, readwrite) int net6ShotsControlPacketForwardDelayRange; // in ms (default 50)
@property (nonatomic, readwrite) int net6ShotsControlPacketForwardDelayBase; // in ms (default 20)

@property (nonatomic, readwrite) int net6ShotsPacketForwardDelayRange; // in ms (default 100)
@property (nonatomic, readwrite) int net6ShotsPacketForwardDelayBase; // in ms (default 30)

@property (nonatomic, readwrite) int net6ShotsOverlayMaintenanceDelay; // in ms (default 5000)


@property (nonatomic, readwrite) int netDeviceTransmissionRange; // in meters (default 40)

- (instancetype)init;

+ (MHConfig*)getSingleton;

- (void)setDefaults;


@end

#endif
