//
//  MHMultihop.m
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHUnicastSocket.h"


@interface MHUnicastSocket () <MHUnicastControllerDelegate>

@property (nonatomic, strong) MHUnicastController *mhController;

@end

@implementation MHUnicastSocket

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:MHUnicastFloodingProtocol];
}

- (instancetype)initWithServiceType:(NSString *)serviceType
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:protocol];
}

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    self = [super init];
    if (self)
    {
        self.mhController = [[MHUnicastController alloc] initWithServiceType:serviceType
                                                                 displayName:displayName
                                                         withRoutingProtocol:protocol];

        self.mhController.delegate = self;
    }
    return self;
}

- (void)dealloc
{

}


#pragma mark - MHUnicastController Delegates
- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
               isDiscovered:(NSString *)info
                       peer:(NSString *)peer
                displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MHUnicastSocketDelegate>)self.delegate mhUnicastSocket:self
                                                       isDiscovered:info
                                                               peer:peer
                                                        displayName:displayName];
    });
}

- (void)mhUnicastController:(MHUnicastController *)mhUnicastController
            hasDisconnected:(NSString *)info
                       peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MHUnicastSocketDelegate>)self.delegate mhUnicastSocket:self
                                                    hasDisconnected:info
                                                               peer:peer];
    });
}
@end
