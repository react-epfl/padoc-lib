//
//  MHNodeManager.h
//  Multihop
//
//  Created by quarta on 16/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHMultipeerWrapper_h
#define Multihop_MHMultipeerWrapper_h


#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MHPeer.h"

#define MH_SERVICE_PREFIX @"mh-"

@protocol MHMultipeerWrapperDelegate;

@interface MHMultipeerWrapper : NSObject

#pragma mark - Properties
@property (nonatomic, weak) id<MHMultipeerWrapperDelegate> delegate;
@property (nonatomic, readonly, strong) NSString *serviceType;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (void)connectToAll;

- (void)disconnectFromAll;

- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
        reliable:(BOOL)reliable
           error:(NSError **)error;

- (NSString *)getOwnPeer;

@end

@protocol MHMultipeerWrapperDelegate <NSObject>

@required
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
     hasConnected:(NSString *)info
             peer:(NSString *)peer
      displayName:(NSString *)displayName;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  failedToConnect:(NSError *)error;

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
   didReceiveData:(NSData *)data
         fromPeer:(NSString *)peer;
@end



#endif
