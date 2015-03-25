//
//  MHMultihop.m
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHMultihop.h"


@interface MHMultihop () <MHMultipeerWrapperDelegate>

@property (nonatomic, readwrite) BOOL serviceStarted;
@property (nonatomic, readwrite, strong) NSString *serviceType;

@property (nonatomic, strong) MHMultipeerWrapper *mcWrapper;
@property (nonatomic, strong) MHBackgroundManager *bgManager;
@end

@implementation MHMultihop

#pragma mark - Life Cycle

- (instancetype)initWithServiceType:(NSString *)serviceType
{
    return [self initWithServiceType:serviceType
                         displayName:[UIDevice currentDevice].name];
}

- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.mcWrapper = [[MHMultipeerWrapper alloc] initWithServiceType:serviceType
                                                             displayName:displayName];
        self.mcWrapper.delegate = self;
        
        self.bgManager = [[MHBackgroundManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.mcWrapper  = nil;
    self.bgManager = nil;
}

#pragma mark - Membership

- (void)connectToAll
{
    [self.mcWrapper connectToAll];
}


- (void)disconnectFromAll
{
    [self.mcWrapper disconnectFromAll];
}

#pragma mark - Communicate

- (void)sendData:(NSData *)data
        reliable:(BOOL)reliable
           error:(NSError **)error
{
    [self.mcWrapper sendData:data
                    reliable:reliable
                       error:error];
}

- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
        reliable:(BOOL)reliable
           error:(NSError **)error
{
    [self.mcWrapper sendData:data
                     toPeers:peers
                    reliable:reliable
                       error:error];
}

- (NSString *)getOwnPeer
{
    return [self.mcWrapper getOwnPeer];
}


#pragma mark - Background Mode methods
- (void)applicationWillResignActive {
    [self.bgManager applicationWillResignActive];
}

- (void)applicationDidBecomeActive{
    [self.bgManager applicationDidBecomeActive];
}



# pragma mark - Termination method
- (void)applicationWillTerminate {
    [self.mcWrapper disconnectFromAll];
    self.mcWrapper = nil;
    self.bgManager = nil;
}




#pragma mark - MHMultipeerWrapper Delegates
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self hasDisconnected:info peer:peer];
    });
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self hasConnected:info peer:peer displayName:displayName];
    });
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhHandler:self failedToConnect:error];
    });
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
   didReceiveData:(NSData *)data
         fromPeer:(NSString *)peer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mhHandler:didReceiveData:fromPeer:)])
        {
            [self.delegate mhHandler:self didReceiveData:data fromPeer:peer];
        }
    });
}

@end
