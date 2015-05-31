//
//  MHSUATPConnection.m
//  Multihop
//
//  Created by quarta on 16/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHSUATPConnection.h"



@interface MHSUATPConnection ()

@property (nonatomic, strong) NSString *targetPeer;

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL handshakeInitiated;

// Must be understood as: stream as been corrected sent until msg seqNumber (included)
@property (nonatomic) NSUInteger seqNumber;
// Must be understood as: stream as been corrected received until msg targetSeqNumber (included)
@property (nonatomic) NSUInteger targetSeqNumber;

@property (nonatomic, strong) NSMutableArray *tempMessagesBuffer;

@end

@implementation MHSUATPConnection

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
        self.targetSeqNumber = 0;
        
        self.tempMessagesBuffer = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.tempMessagesBuffer removeAllObjects];
    self.tempMessagesBuffer = nil;
}


#pragma mark - Communicate
- (void)sendMessage:(MHMessage *)message
{
    // Dummy procedure
    [self.delegate MHSUATPConnection:self
                                    sendMessage:message
                                         toPeer:self.targetPeer];
    return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.connected) // if still not connected, put into temporary buffer
        {
            [self.tempMessagesBuffer addObject:message];
        }
        else
        {
            
        }
    });
    
    //self.seqNumber++;
    //message.seqNumber = self.seqNumber;
}


- (void)processIncomingMessage:(MHMessage *)message withTraceInfo:(NSArray *)traceInfo
{
    // Dummy procedure
    [self.delegate MHSUATPConnection:self
                              didReceiveMessage:message
                                       fromPeer:self.targetPeer
                                  withTraceInfo:traceInfo];
    return;
}


# pragma mark - Dispatching between handshake or normal messages
- (void)messageReceived:(MHMessage *)message
          withTraceInfo:(NSArray *)traceInfo
{
    // Dummy call
    [self processIncomingMessage:message withTraceInfo:traceInfo];
    return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
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
            [self.delegate MHSUATPConnection:self
                                            sendMessage:synMessage
                                                 toPeer:self.targetPeer];
        });
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_SUATP_TIMEOUT_MS * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            if (!self.connected) // if still not connected, then throw an exception
            {
                // An error occurred
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate MHSUATPConnection:self
                                                 isDisconnected:@"Handshake failure"
                                                           peer:self.targetPeer];
                });
            }
        });
        
        // No errors occurred
        return;
    }
    
    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHSUATPConnection:self
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
        self.targetSeqNumber = message.seqNumber;
        
        synackMessage.seqNumber = self.seqNumber;
        synackMessage.ackNumber = self.targetSeqNumber;
        
        self.handshakeInitiated = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate MHSUATPConnection:self
                                            sendMessage:synackMessage
                                                 toPeer:self.targetPeer];
        });
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_SUATP_TIMEOUT_MS * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            if (!self.connected) // if still not connected, then throw an exception
            {
                // An error occurred
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate MHSUATPConnection:self
                                                 isDisconnected:@"Handshake failure"
                                                           peer:self.targetPeer];
                });
            }
        });
        
        // No errors occurred
        return;
    }

    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHSUATPConnection:self
                                     isDisconnected:@"Handshake failure"
                                               peer:self.targetPeer];
    });
}

- (void)sinackReceived:(MHMessage *)message
{
    if (!self.connected)
    {
        if (message.ackNumber == self.seqNumber)
        {
            self.seqNumber++;
            
            MHMessage *ackMessage = [[MHMessage alloc] initWithData:[MHComputation emptyData]];
            
            ackMessage.sin = NO;
            self.targetSeqNumber =  message.seqNumber;
            
            ackMessage.seqNumber = self.seqNumber;
            ackMessage.ackNumber = self.targetSeqNumber;
            
            [self setConnectionEnabled];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate MHSUATPConnection:self
                                                sendMessage:ackMessage
                                                     toPeer:self.targetPeer];
            });
            
            // No errors occurred
            return;
        }
    }

    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHSUATPConnection:self
                                     isDisconnected:@"Handshake failure"
                                               peer:self.targetPeer];
    });
}

- (void)ackReceived:(MHMessage *)message
{
    if (message.ackNumber == self.seqNumber)
    {
        self.targetSeqNumber = message.seqNumber;
        
        [self setConnectionEnabled];
        
        // No errors occurred
        return;
    }
    
    // An error occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate MHSUATPConnection:self
                                     isDisconnected:@"Handshake failure"
                                               peer:self.targetPeer];
    });
}

# pragma mark - Helper methods

- (void)setConnectionEnabled
{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connected = true;
    });
}

@end