/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef Padoc_MHLocationManager_h
#define Padoc_MHLocationManager_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MHComputation.h"
#import "MHConfig.h"


@interface MHLocation : NSObject<NSCoding>

@property (nonatomic, readwrite) double x;
@property (nonatomic, readwrite) double y;

- (instancetype)init;

@end



@interface MHLocationManager : NSObject

- (instancetype)initWithBeaconID:(NSString*)beaconID
                         withGPS:(BOOL)useGPS
                      withBeacon:(BOOL)useBeacon;

- (void)start;
- (void)stop;

- (void)registerBeaconRegionWithUUID:(NSString *)proximityUUID;
- (void)unregisterBeaconRegionWithUUID:(NSString *)proximityUUID;

- (MHLocation*)getMPosition;
- (MHLocation*)getGPSPosition;

- (CLProximity)getProximityForUUID:(NSString *)proximityUUID;

+ (void)setBeaconIDWithPeerID:(NSString*)peerID;
+ (void)useGPS:(BOOL)use;
+ (void)useBeacon:(BOOL)use;
+ (MHLocationManager*)getSingleton;

+ (double)getDistanceFromMLocation:(MHLocation*)l1 toMLocation:(MHLocation*)l2;

+ (double)getDistanceFromGPSLocation:(MHLocation*)l1 toGPSLocation:(MHLocation*)l2;

@end


#endif
