//
//  MHBackgroundManager.h
//  Multihop
//
//  Created by quarta on 24/03/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef Multihop_MHBackgroundManager_h
#define Multihop_MHBackgroundManager_h

#import <Foundation/Foundation.h>
#import "MHMultipeerWrapper.h"


@protocol MHBackgroundManagerDelegate;

@interface MHBackgroundManager : NSObject

#pragma mark - Properties

/// Delegate for the MHBackgroundManager methods
@property (nonatomic, weak) id<MHBackgroundManagerDelegate> delegate;



#pragma mark - Initialization


- (instancetype)initWithMultipeerWrapper:(MHMultipeerWrapper *)mcWrapper;




- (void)applicationDidEnterBackground:(UIApplication *)application;

- (void)applicationWillEnterForeground:(UIApplication *)application;


@end

/**
 The delegate for the MHMultipeerWrapperDelegate class.
 */
@protocol MHBackgroundManagerDelegate <NSObject>

@required
/*
- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper
  hasDisconnected:(NSString *)info
             peer:(NSString *)peer;
*/

@optional

@end


#endif
