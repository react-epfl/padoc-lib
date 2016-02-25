/*
 Copyright (c) 2016 REACT EPFL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MHRoutingProtocol.h"



@interface MHRoutingProtocol () <MHConnectionsHandlerDelegate>

@property (nonatomic, strong) NSMutableArray *neighbourPeers;
@property (nonatomic, strong) MHConnectionsHandler *cHandler;
@end

@implementation MHRoutingProtocol

#pragma mark - Initialization
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName
{
    self = [super init];
    if (self)
    {
        self.neighbourPeers = [[NSMutableArray alloc] init];
        self.cHandler = [[MHConnectionsHandler alloc] initWithServiceType:serviceType
                                                              displayName:displayName];
        
        self.cHandler.delegate = self;
        
        [[MHDiagnostics getSingleton] reset];
    }
    return self;
}

- (void)dealloc
{
    self.neighbourPeers = nil;
    self.cHandler = nil;
}

- (void)disconnect
{
    [self.neighbourPeers removeAllObjects];
    [self.cHandler disconnectFromNeighbourhood];
    
    // Can override, but must call the super method
}

- (NSString *)getOwnPeer
{
    return [self.cHandler getOwnPeer];
}

- (void)applicationWillResignActive
{
    [self.cHandler applicationWillResignActive];
}

- (void)applicationDidBecomeActive
{
    [self.cHandler applicationDidBecomeActive];
}


#pragma mark - Overridable methods
- (void)sendPacket:(MHPacket *)packet
           maxHops:(int)maxHops
             error:(NSError **)error
{
    // Must be overridden
}

- (int)hopsCountFromPeer:(NSString*)peer
{
    // Must be overridden
    return 0;
}

- (void)joinGroup:(NSString *)groupName
          maxHops:(int)maxHops
{
    // Must be overridden
}

- (void)leaveGroup:(NSString *)groupName
           maxHops:(int)maxHops
{
    // Must be overridden
}

#pragma mark - Connectionshandler delegate methods
- (void)cHandler:(MHConnectionsHandler *)cHandler
 failedToConnect:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mhProtocol:self failedToConnect:error];
    });
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
    hasConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
    // Must be overridden
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
 hasDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    // Must be overridden
}


- (void)cHandler:(MHConnectionsHandler *)cHandler
didReceiveDatagram:(MHDatagram *)datagram
        fromPeer:(NSString *)peer
{
    // Must be overridden
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
  enteredStandby:(NSString *)info
            peer:(NSString *)peer
{
    // Must be overridden
}

- (void)cHandler:(MHConnectionsHandler *)cHandler
   leavedStandby:(NSString *)info
            peer:(NSString *)peer
{
    // Must be overridden
}
@end
