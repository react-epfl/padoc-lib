//
//  MHMulticastController.m
//  Multihop
//
//  Created by quarta on 03/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHMulticastController.h"

@interface MHMulticastController () <MHMulticastRoutingProtocolDelegate>

@property (nonatomic, strong) MHRoutingProtocol *mhProtocol;
@end

@implementation MHMulticastController

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
                withRoutingProtocol:(MHRoutingProtocols)protocol
{
    self = [super init];
    if (self)
    {
        switch (protocol) {
            case MHMulticast6ShotsProtocol:
                self.mhProtocol = [[MH6ShotsProtocol alloc] initWithServiceType:serviceType
                                                                    displayName:displayName];
                break;
                
            default:
                self.mhProtocol = [[MH6ShotsProtocol alloc] initWithServiceType:serviceType
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

#pragma mark - Communicate

- (void)joinGroup:(NSString *)groupName
{
    [(MHMulticastRoutingProtocol*)self.mhProtocol joinGroup:groupName];
}

- (void)leaveGroup:(NSString *)groupName
{
    [(MHMulticastRoutingProtocol*)self.mhProtocol leaveGroup:groupName];
}



#pragma mark - MHMulticastRoutingProtocol Delegates

#pragma mark - Diagnostics info callbacks
- (void)mhProtocol:(MHMulticastRoutingProtocol *)mhProtocol
       joinedGroup:(NSString *)info
              peer:(NSString *)peer
             group:(NSString *)group
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id<MHMulticastControllerDelegate>)self.delegate mhMulticastController:self
                                                                    joinedGroup:info
                                                                           peer:peer
                                                                          group:group];
    });
}

@end