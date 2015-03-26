//
//  MHConnectionsHandler.h
//  consoleViewer
//
//  Created by quarta on 25/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef consoleViewer_MHConnectionsHandler_h
#define consoleViewer_MHConnectionsHandler_h


#import <Foundation/Foundation.h>
#import "MHMultipeerWrapper.h"


/**
 
 This layer has 2 purposes:
 - Limit the outgoing trafic throughput, so that the
 low level API does not get saturated (and errors occur).
 
 - Hide to the above layers the disconnection/reconnection process
 that randomly occur between peers (for example, when switching background tasks).
 Messages sent during that short period are buffered and sent later.
 
 **/


@protocol MHConnectionsHandlerDelegate;

@interface MHConnectionsHandler : NSObject

#pragma mark - Properties
@property (nonatomic, weak) id<MHConnectionsHandlerDelegate> delegate;


#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

- (void)connectToAll;

- (void)disconnectFromAll;

- (void)sendData:(NSData *)data
           error:(NSError **)error;

- (void)sendData:(NSData *)data
         toPeers:(NSArray *)peers
           error:(NSError **)error;

- (NSString *)getOwnPeer;

@end

@protocol MHConnectionsHandlerDelegate <NSObject>

@required
- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer;

- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName;

- (void)cHandler:(MHConnectionsHandler *)cHandler
 failedToConnect:(NSError *)error;

@optional
- (void)cHandler:(MHConnectionsHandler *)cHandler
  didReceiveData:(NSData *)data
        fromPeer:(NSString *)peer;
@end



#endif
