//
//  MHLocationManager.m
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHLocationManager.h"




@interface MHLocation ()

@property (nonatomic) double x;
@property (nonatomic) double y;

@end


@implementation MHLocation

- (instancetype)init;
{
    self = [super init];
    
    return self;
}

@end




@interface MHLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) MHLocation *position;

@end

static MHLocationManager *locationManager = nil;

@implementation MHLocationManager

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        self.locationManager.delegate = self;
        self.position = [[MHLocation alloc] init];
        
        CLLocation *curPos = self.locationManager.location;

        self.position.x = curPos.coordinate.latitude;
        self.position.y = curPos.coordinate.longitude;
    }
    return self;
}

- (void)start
{
    [self.locationManager startUpdatingLocation];
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
}

- (MHLocation*)getPosition
{
    MHLocation *loc;
    loc.x = self.position.x;
    loc.y = self.position.y;
    
    return loc;
}



- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
    self.position.x = newLocation.coordinate.latitude;
    self.position.y = newLocation.coordinate.longitude;
}

- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error
{
    NSLog(@"%@", @"Core location can't get a fix.");
}


+ (MHLocationManager*)getSingleton
{
    if (locationManager == nil)
    {
        locationManager = [[MHLocationManager alloc] init];
    }
    
    return locationManager;
}



+ (double)getDistanceFromLocation:(MHLocation*)l1 toLocation:(MHLocation*)l2
{
    // TODO changes???
    return sqrt(pow((l2.x - l1.x), 2) + pow((l2.y - l1.y), 2));
}
@end
