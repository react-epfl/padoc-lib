//
//  MHUnicastTransportConnection.m
//  Multihop
//
//  Created by quarta on 16/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHUnicastTransportConnection.h"



@interface MHUnicastTransportConnection ()

@property (nonatomic, strong) NSString *targetPeer;
@end

@implementation MHUnicastTransportConnection

#pragma mark - Life Cycle
- (instancetype)initWithTargetPeer:(NSString*)targetPeer
{
    self = [super init];
    if (self)
    {
        self.targetPeer = targetPeer;
    }
    return self;
}

- (void)dealloc
{

}


#pragma mark - Communicate

- (void)handshake
{
    MHMessage *synMessage = [[MHMessage alloc] initWithData:[MHComputation emptyData]];
    synMessage.sin = YES;
    synMessage.seqNumber = arc4random_uniform(MH_SUATP_MAX_INITIAL_SEQ_NUMBER);
    
    [self.delegate MHUnicastTransportConnection:self
                                    sendMessage:synMessage
                                         toPeer:self.targetPeer];
}

- (void)sendMessage:(MHMessage *)message
{

}

- (void)messageReceived:(MHMessage *)message
          withTraceInfo:(NSArray *)traceInfo
{
    
}

@end