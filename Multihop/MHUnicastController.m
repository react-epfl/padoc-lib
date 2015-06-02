//
//  MHUnicastController.m
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHUnicastController.h"


@interface MHUnicastController () <MHUnicastRoutingProtocolDelegate>

@property (nonatomic, strong) MHUnicastRoutingProtocol *mhProtocol;
@end

@implementation MHUnicastController

#pragma mark - Life Cycle
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    self = [super init];
    if (self)
    {
        switch (protocol) {
            case MHUnicastFloodingProtocol:
                self.mhProtocol = [[MHFloodingProtocol alloc] initWithServiceType:serviceType
                                                                      displayName:displayName];
                break;
                
            default:
                self.mhProtocol = [[MHFloodingProtocol alloc] initWithServiceType:serviceType
                                                                      displayName:displayName];
                break;
        }
        
        self.mhProtocol.delegate = self;
    }
    return self;
}

- (void)dealloc
{

}


#pragma mark - MHUnicastRoutingProtocol Delegates

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
      isDiscovered:(NSString *)info
              peer:(NSString *)peer
       displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MHUnicastControllerDelegate>)self.delegate mhUnicastController:self
                                                               isDiscovered:info
                                                                       peer:peer
                                                                displayName:displayName];
    });
}

- (void)mhProtocol:(MHUnicastRoutingProtocol *)mhProtocol
   hasDisconnected:(NSString *)info
              peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MHUnicastControllerDelegate>)self.delegate mhUnicastController:self hasDisconnected:info peer:peer];
    });
}

@end