//
//  MHLocationManager.m
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHLocationManager.h"




@interface MHLocation ()

@end


@implementation MHLocation

- (instancetype)init;
{
    self = [super init];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.x = [decoder decodeDoubleForKey:@"x"];
        self.y = [decoder decodeDoubleForKey:@"y"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.x forKey:@"x"];
    [encoder encodeDouble:self.y forKey:@"y"];
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
        self.locationManager.delegate = self;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.position = [[MHLocation alloc] init];
        
        CLLocation *curPos = self.locationManager.location;

        self.position.x = curPos.coordinate.longitude;
        self.position.y = curPos.coordinate.latitude;
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

- (MHLocation*)getGPSPosition
{
    MHLocation *loc = [[MHLocation alloc] init];
    loc.x = self.position.x;
    loc.y = self.position.y;
    
    return loc;
}

- (MHLocation*)getMPosition
{
    MHLocation *loc = [[MHLocation alloc] init];
    
    MHLocation *origin = [[MHLocation alloc] init];
    origin.x = 0.0;
    origin.y = 0.0;
    
    MHLocation *target = [[MHLocation alloc] init];
    
    // X
    target.x = self.position.x;
    target.y = 0.0;
    loc.x = [MHLocationManager getDistanceFromGPSLocation:origin toGPSLocation:target] * [MHLocationManager sign:self.position.x];
    
    // Y
    target.x = 0.0;
    target.y = self.position.y;
    loc.y = [MHLocationManager getDistanceFromGPSLocation:origin toGPSLocation:target] * [MHLocationManager sign:self.position.y];
    
    return loc;
}



- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
    self.position.x = newLocation.coordinate.longitude;
    self.position.y = newLocation.coordinate.latitude;
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


// We assume these are meter coordinates
+ (double)getDistanceFromMLocation:(MHLocation*)l1 toMLocation:(MHLocation*)l2
{
    return sqrt(pow((l2.x - l1.x), 2) + pow((l2.y - l1.y), 2));
}


// We assume these are GPS coordinates
+ (double)getDistanceFromGPSLocation:(MHLocation*)l1 toGPSLocation:(MHLocation*)l2
{
    double R = 6371000.0; // Earth radius (m)
    double dLat = [self toRad:(l2.y-l1.y)];
    double dLon = [self toRad:(l2.x-l1.x)];
    double lat1 = [self toRad:l1.y];
    double lat2 = [self toRad:l2.y];
    
    double a = sin(dLat/2.0) * sin(dLat/2.0) + sin(dLon/2.0) * sin(dLon/2.0) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1.0-a));
    double d = R * c;
    
    return d;
}


#pragma mark - GPS helper methods
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
@end
