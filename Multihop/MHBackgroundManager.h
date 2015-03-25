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




#pragma mark - Initialization


- (instancetype)init;



- (void)applicationWillResignActive;

- (void)applicationDidBecomeActive;

@end


#endif
