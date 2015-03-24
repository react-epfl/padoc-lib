//
//  MHBackgroundManager.m
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "MHBackgroundManager.h"



@interface MHBackgroundManager ()

@property (nonatomic, strong) MHMultipeerWrapper *mcWrapper;
@end

@implementation MHBackgroundManager

#pragma mark - Life Cycle

- (instancetype)initWithMultipeerWrapper:(MHMultipeerWrapper *)mcWrapper
{
    self = [super init];
    if (self)
    {
        self.mcWrapper = mcWrapper;
    }
    return self;
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"background entered");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


@end