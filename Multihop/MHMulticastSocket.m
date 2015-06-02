//
//  MHMulticastSocket.m
//  Multihop
//
//  Created by quarta on 05/04/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//


#import "MHMulticastSocket.h"


@interface MHMulticastSocket () <MHMulticastControllerDelegate>

@property (nonatomic, strong) MHMulticastController *mhController;
@end

@implementation MHMulticastSocket

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name
                 withRoutingProtocol:MHMulticast6ShotsProtocol];
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
        self.mhController = [[MHMulticastController alloc] initWithServiceType:serviceType
                                                                   displayName:displayName
                                                           withRoutingProtocol:protocol];
        
        self.mhController.delegate = self;
    }
    return self;
}

- (void)dealloc
{

}

#pragma mark - Communicate

- (void)joinGroup:(NSString *)groupName
{
    [self.mhController joinGroup:groupName];
}

- (void)leaveGroup:(NSString *)groupName
{
    [self.mhController leaveGroup:groupName];
}


#pragma mark - MHUnicastRoutingProtocol Delegates

#pragma mark - Diagnostics info callbacks
- (void)mhMulticastController:(MHMulticastController *)mhMulticastController
                  joinedGroup:(NSString *)info
                         peer:(NSString *)peer
                        group:(NSString *)group
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhMulticastSocket:joinedGroup:peer:group:)])
        {
            [(id<MHMulticastSocketDelegate>)self.delegate mhMulticastSocket:self
                                                                joinedGroup:info
                                                                       peer:peer
                                                                      group:group];
        }
    });
}

@end
