//
//  MHSUATPConnection.m
//  Multihop
//
//  Created by quarta on 16/05/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHSUATPConnection.h"

// TODO: what if no ack is never received???

@interface MHSUATPConnection ()

@property (nonatomic, strong) NSString *targetPeer;

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL handshakeInitiated;

// Must be understood as: stream as been corrected sent until msg seqNumber (included)
@property (nonatomic) NSUInteger seqNumber;
// Must be understood as: stream as been corrected received until msg targetSeqNumber (included)
@property (nonatomic) NSUInteger targetSeqNumber;

@property (nonatomic, strong) NSMutableArray *tempMessagesBuffer;

// Message sending buffers
@property (nonatomic, strong) MHSUATPBuffer *transmittedBuffer;
@property (nonatomic, strong) MHSUATPBuffer *queuedSendingBuffer; // Normal priority
@property (nonatomic, strong) MHSUATPBuffer *retransmittingBuffer; // High priority

// Message receiving buffers
//@property (nonatomic, strong) MHSUATPBuffer *queuedReceivingBuffer; // Normal received buffer
//@property (nonatomic, strong) MHSUATPBuffer *stockedBuffer; //


// Congestion parameters
@property (nonatomic) NSUInteger sendDelay;
@property (nonatomic) NSUInteger receiveDelay;


// Loop functions
@property (copy) void (^dequeueSendingMessages)(void);
//@property (copy) void (^dequeueReceivingMessages)(void);
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
        
        // Buffers initialization
        self.transmittedBuffer = [[MHSUATPBuffer alloc] init];
        
        self.queuedSendingBuffer = [[MHSUATPBuffer alloc] init];
        
        self.retransmittingBuffer = [[MHSUATPBuffer alloc] init];
        
        
        // Congestion
        self.sendDelay = MH_SUATP_DEFAULT_SENDING_DELAY;
        //self.receiveDelay = MH_SUATP_DEFAULT_RECEIVING_DELAY;
        
        // Loop functions
        MHSUATPConnection * __weak weakSelf = self;
        [self setFctDequeueSendingMessages:weakSelf];
        //[self setFctDequeueReceivingMessages:weakSelf];
    }
    return self;
}

- (void)dealloc
{
    [self.tempMessagesBuffer removeAllObjects];
    self.tempMessagesBuffer = nil;
    
    self.transmittedBuffer = nil;
    self.queuedSendingBuffer = nil;
    self.retransmittingBuffer = nil;
}


#pragma mark - Loop functions

- (void)setFctDequeueSendingMessages:(MHSUATPConnection * __weak)weakSelf
{
    self.dequeueSendingMessages = ^{
        if (weakSelf)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf.retransmittingBuffer.isEmpty)
                {
                    [weakSelf processSendingMessage:[weakSelf.retransmittingBuffer popMessage].message
                                       withWeakSelf:weakSelf];
                }
                else
                {
                    [weakSelf processSendingMessage:[weakSelf.queuedSendingBuffer popMessage].message
                                       withWeakSelf:weakSelf];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_SUATP_DEFAULT_SENDING_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.dequeueSendingMessages);
            });
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_SUATP_DEFAULT_SENDING_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.dequeueSendingMessages);
}

/*
- (void)setFctDequeueReceivingMessages:(MHSUATPConnection * __weak)weakSelf
{
    self.dequeueReceivingMessages = ^{
        if (weakSelf)
        {
            [self.qu]
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_FLOODING_SCHEDULECLEANING_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.processedPacketsCleaning);
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MH_SUATP_DEFAULT_RECEIVING_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.dequeueReceivingMessages);
}
*/
 
 
#pragma mark - Communicate
- (void)sendMessage:(MHMessage *)message
{
    // Dummy procedure
    [self.delegate MHSUATPConnection:self
                         sendMessage:message
                              toPeer:self.targetPeer];
    return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.seqNumber++;
        message.seqNumber = self.seqNumber;
        
        if(!self.connected) // if still not connected, put into temporary buffer
        {
            [self.tempMessagesBuffer addObject:message];
        }
        else
        {
            [self.queuedSendingBuffer pushMessage:message withTraceInfo:nil];
        }
    });
}


- (void)processIncomingMessage:(MHMessage *)message withTraceInfo:(NSArray *)traceInfo
{
    // Dummy procedure
    [self.delegate MHSUATPConnection:self
                   didReceiveMessage:message
                            fromPeer:self.targetPeer
                       withTraceInfo:traceInfo];
    return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (message.ack == YES) // Ack message
        {
            [self processAckMessage:message];
        }
        else // Normal packet
        {
            // TODO
        }
    });
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
        for (id msg in self.tempMessagesBuffer)
        {
            [self.queuedSendingBuffer pushMessage:msg withTraceInfo:nil];
        }
        
        [self.tempMessagesBuffer removeAllObjects];
        
        self.connected = true;
    });
}




#pragma mark - Sending buffers logic
- (void)processSendingMessage:(MHMessage *)message
                 withWeakSelf:(MHSUATPConnection * __weak)weakSelf
{
    if (message != nil)
    {
        // We send to target peer, but we put into trasmitted buffer
        // if a retransmission is needed
        [weakSelf.delegate MHSUATPConnection:weakSelf sendMessage:message toPeer:weakSelf.targetPeer];
        
        [weakSelf.transmittedBuffer pushMessage:message withTraceInfo:nil];
    }
}


#pragma mark - Receiving message logic
- (void)processAckMessage:(MHMessage *)message
{
    MHSUATPAckMessageContent *content = [NSKeyedUnarchiver unarchiveObjectWithData:message.data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // ClearUntil is not async!!
        if (content.missingMessages.count > 0)
        {
            NSUInteger firstMissing = [content.missingMessages[0] integerValue];
            
            [self.transmittedBuffer clearUntil:firstMissing - 1]; // We do not erase the first missing message as well!
        }
        else
        {
            [self.transmittedBuffer clearUntil:content.lastReceivedMessage];
        }
        
        MHSUATPBufferMessage *transmittedMsg = [self.transmittedBuffer popMessage];
        
        while (transmittedMsg != nil)
        {
            if([content.missingMessages containsObject:[NSNumber numberWithUnsignedInteger:transmittedMsg.message.seqNumber]] || transmittedMsg.message.seqNumber > content.lastReceivedMessage)
            {
                // We put into retransmission buffer if the message is one
                // of the missing ones or the receiver does not know that it exists
                [self.retransmittingBuffer pushMessage:transmittedMsg.message withTraceInfo:transmittedMsg.traceInfo];
            }
            
            transmittedMsg = [self.transmittedBuffer popMessage];
        }
    });
}
@end