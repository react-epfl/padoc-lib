//
//  MHBackgroundManager.m
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHBackgroundManager.h"



@interface MHBackgroundManager ()


@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@property (copy) void (^backgroundTaskEndHandler)(void);

@end

@implementation MHBackgroundManager

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Background task end handler
        MHBackgroundManager * __weak weakSelf = self;
        
        self.backgroundTaskEndHandler = ^{
            //This is called 3 seconds before the time expires
            //Here: Kill the session, advertisers, nil its delegates,
            //      which should correctly send a disconnect signal to other peers
            //      it's important if we want to be able to reconnect later,
            //      as the MC framework is still buggy
            
            UIBackgroundTaskIdentifier newTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:weakSelf.backgroundTaskEndHandler];
            
            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTask];
            
            weakSelf.backgroundTask = newTask;
        };
    }
    
    return self;
}

- (void)applicationWillResignActive
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:self.backgroundTaskEndHandler];
}


- (void)applicationDidBecomeActive
{
    self.backgroundTask = UIBackgroundTaskInvalid;
}

@end