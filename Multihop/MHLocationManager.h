//
//  MHLocationManager.h
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHLocationManager_h
#define Multihop_MHLocationManager_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface MHLocation : NSObject

@property (nonatomic, readwrite) double x;
@property (nonatomic, readwrite) double y;

- (instancetype)init;

@end



@interface MHLocationManager : NSObject

- (instancetype)init;

- (void)start;

- (void)stop;

- (MHLocation*)getPosition;


+ (MHLocationManager*)getSingleton;

+ (double)getDistanceFromLocation:(MHLocation*)l1 toLocation:(MHLocation*)l2;

@end


#endif
