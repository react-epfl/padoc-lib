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




@interface MHLocationManager () <CLLocationManagerDelegate, CBPeripheralManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) MHLocation *position;

@property (nonatomic, strong) NSMutableDictionary *beacons;
@property (nonatomic, strong) NSMutableDictionary *beaconsProximity;
@property (nonatomic, strong) CLBeaconRegion *ownBeaconRegion;
@property (nonatomic, strong) NSDictionary *beaconPeripheralData;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic) BOOL started;
@property (nonatomic) BOOL beaconActive;
@property (nonatomic) BOOL useGPS;

@end


#pragma mark - Singleton static variables

static MHLocationManager *locationManager = nil;
static NSString *beaconID = @"";




@implementation MHLocationManager

- (instancetype)initWithBeaconID:(NSString*)beaconID
                         withGPS:(BOOL) useGPS
{
    self = [super init];
    
    if(self)
    {
        self.useGPS = useGPS;
        
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
        
        
        self.started = NO;
        self.beaconActive = NO;
        self.beacons = [[NSMutableDictionary alloc] init];
        self.beaconsProximity = [[NSMutableDictionary alloc] init];
        
        // Create the beacon region.
        self.ownBeaconRegion = [[CLBeaconRegion alloc]
                                initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:beaconID]
                                           identifier:[MHIdGenerator makeUniqueStringFromSource:beaconID]];
        
        // Create a dictionary of advertisement data.
        self.beaconPeripheralData = [self.ownBeaconRegion peripheralDataWithMeasuredPower:nil];
        
        // Create the peripheral manager.
        self.peripheralManager = [[CBPeripheralManager alloc]
                                 initWithDelegate:self queue:nil options:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.beacons removeAllObjects];
    self.beacons = nil;
    [self.beaconsProximity removeAllObjects];
    self.beaconsProximity = nil;
    self.locationManager = nil;
}

- (void)start
{
    if(self.useGPS)
    {
        [self.locationManager startUpdatingLocation];
    }
  
    for (id beaconKey in self.beacons.allKeys)
    {
        CLBeaconRegion *beacon = [self.beacons objectForKey:beaconKey];
        
        [self.locationManager startMonitoringForRegion:beacon];
        [self.locationManager startRangingBeaconsInRegion:beacon];
    }
    
    if(self.beaconActive)
    {
        // Start advertising the beacon's data.
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    }
    
    self.started = YES;
}

- (void)stop
{
    if(self.useGPS)
    {
        [self.locationManager stopUpdatingLocation];
    }
    
    for (id beaconKey in self.beacons.allKeys)
    {
        CLBeaconRegion *beacon = [self.beacons objectForKey:beaconKey];
        
        [self.locationManager stopMonitoringForRegion:beacon];
        [self.locationManager stopRangingBeaconsInRegion:beacon];
    }
    
    [self.peripheralManager stopAdvertising];
    
    self.started = NO;
}


- (void)registerBeaconRegionWithUUID:(NSString *)proximityUUID
{
    
    // Create the beacon region to be monitored.
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                    initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:proximityUUID]
                                    identifier:[MHIdGenerator makeUniqueStringFromSource:proximityUUID]];
    
    [self.beacons setObject:beaconRegion forKey:proximityUUID];
    
    [self.beaconsProximity setObject:@(CLProximityUnknown) forKey:proximityUUID];
    

    if(self.started)
    {
        // Register the beacon region with the location manager.
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}

- (void)unregisterBeaconRegionWithUUID:(NSString *)proximityUUID
{
    CLBeaconRegion *beaconRegion = [self.beacons objectForKey:proximityUUID];

    if(self.started)
    {
        [self.locationManager stopMonitoringForRegion:beaconRegion];
        [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
    }
    
    [self.beacons removeObjectForKey:proximityUUID];
    [self.beaconsProximity removeObjectForKey:proximityUUID];
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


- (CLProximity)getProximityForUUID:(NSString *)proximityUUID
{
    NSNumber *proximity = [self.beaconsProximity objectForKey:proximityUUID];
    
    if(proximity == nil)
    {
        return CLProximityUnknown;
    }
    
    return [proximity integerValue];
}


#pragma mark - CCLocationManagerDelegate methods
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
    NSLog(@"The Location Manager encountered an error");
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] > 0) {
        CLBeacon *nearestExhibit = [beacons firstObject];

        [self.beaconsProximity setObject:@(nearestExhibit.proximity) forKey:[region.proximityUUID UUIDString]];
    }
}

#pragma mark - CBPeripheralManagerDelegate methods
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if(peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        NSLog(@"Ibeacon unsupported");
    }
    else if(peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        if(self.started)
        {
            // Start advertising the beacon's data.
            [self.peripheralManager startAdvertising:self.beaconPeripheralData];
        }
        
        self.beaconActive = YES;
    }
    else if(peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        if (self.started)
        {
            [self.peripheralManager stopAdvertising];
        }
        
        self.beaconActive = NO;
    }
}


#pragma mark - Singleton methods
+ (void)setBeaconIDWithPeerID:(NSString*)peerID
{
    beaconID = peerID;
}

+ (MHLocationManager*)getSingleton
{
    if (locationManager == nil)
    {
        locationManager = [[MHLocationManager alloc] initWithBeaconID:beaconID
                                                              withGPS:YES];
    }
    
    return locationManager;
}



#pragma mark - GPS methods
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
