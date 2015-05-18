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

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL handshakeInitiated;

@property (nonatomic) NSUInteger seqNumber;
@end

@implementation MHUnicastTransportConnection

#pragma mark - Life Cycle
- (instancetype)initWithTargetPeer:(NSString*)targetPeer
{
    self = [super init];
    if (self)
    {
        self.targetPeer = targetPeer;
        
        self.connected = NO;
        self.handshakeInitiated = NO;
        
        self.seqNumber = 0;
    }
    return self;
}

- (void)dealloc
{

}


#pragma mark - Communicate
- (void)sendMessage:(MHMessage *)message
{
    // Dummy procedure
    [self.delegate MHUnicastTransportConnection:self
                                    sendMessage:message
                                         toPeer:self.targetPeer];
}


- (void)processIncomingMessage:(MHMessage *)message withTraceInfo:(NSArray *)traceInfo
{
    // Dummy procedure
    [self.delegate MHUnicastTransportConnection:self
                              didReceiveMessage:message
                                       fromPeer:self.targetPeer
                                  withTraceInfo:traceInfo];
}


# pragma mark - Dispatching between handshake or normal messages
- (void)messageReceived:(MHMessage *)message
          withTraceInfo:(NSArray *)traceInfo
{
    // Dummy call
    [self processIncomingMessage:message withTraceInfo:traceInfo];
    return;
    
    if (message.sin)
    {
        // It's a sin message
        if (!self.handshakeInitiated)
        {
            [self sinReceived:message];
        }
        else // It's a sinack message
        {
            [self sinackReceived:message];
        }
    }
    else
    {
        if (!self.connected) // It's a ack message
        {
            [self ackReceived:message];
        }
        else // It's a normal message
        {
            [self processIncomingMessage:message withTraceInfo:traceInfo];
        }
    }
}


#pragma mark - Handshake protocol
- (void)handshake
{
    // Dummy return
    return;
    
    if (!self.handshakeInitiated && !self.connected)
    {
        MHMessage *synMessage = [[MHMessage alloc] initWithData:[MHComputation emptyData]];
        
        synMessage.sin = YES;
        self.seqNumber = arc4random_uniform(MH_SUATP_MAX_INITIAL_SEQ_NUMBER);
        synMessage.seqNumber = self.seqNumber;
        
        self.handshakeInitiated = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate MHUnicastTransportConnection:self
                                            sendMessage:synMessage
                                                 toPeer:self.targetPeer];
        });
        
        // No errors occurred
        return;
    }
    
    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHUnicastTransportConnection:self
                                     isDisconnected:@"Handshake failure"
                                               peer:self.targetPeer];
    });
}

- (void)sinReceived:(MHMessage *)message
{
    if (!self.connected)
    {
        MHMessage *synackMessage = [[MHMessage alloc] initWithData:[MHComputation emptyData]];
        
        synackMessage.sin = YES;
        self.seqNumber = arc4random_uniform(MH_SUATP_MAX_INITIAL_SEQ_NUMBER);
        synackMessage.seqNumber = self.seqNumber;
        synackMessage.ackNumber = message.seqNumber + 1;
        
        self.handshakeInitiated = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate MHUnicastTransportConnection:self
                                            sendMessage:synackMessage
                                                 toPeer:self.targetPeer];
        });
        
        // No errors occurred
        return;
    }

    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHUnicastTransportConnection:self
                                     isDisconnected:@"Handshake failure"
                                               peer:self.targetPeer];
    });
}

- (void)sinackReceived:(MHMessage *)message
{
    if (!self.connected)
    {
        if (message.ackNumber == self.seqNumber + 1)
        {
            MHMessage *ackMessage = [[MHMessage alloc] initWithData:[MHComputation emptyData]];
            
            ackMessage.sin = NO;
            self.seqNumber = message.ackNumber;
            ackMessage.seqNumber = self.seqNumber;
            ackMessage.ackNumber = message.seqNumber + 1;
            
            self.connected = true;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate MHUnicastTransportConnection:self
                                                sendMessage:ackMessage
                                                     toPeer:self.targetPeer];
            });
            
            // No errors occurred
            return;
        }
    }

    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHUnicastTransportConnection:self
                                     isDisconnected:@"Handshake failure"
                                               peer:self.targetPeer];
    });
}

- (void)ackReceived:(MHMessage *)message
{
    if (message.ackNumber == self.seqNumber + 1)
    {
        self.connected = true;
        
        // No errors occurred
        return;
    }
    
    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHUnicastTransportConnection:self
                                     isDisconnected:@"Handshake failure"
                                               peer:self.targetPeer];
    });
}

@end