//
//  AppDelegate.h
//  padoc-lib
//
//  Created by Gabriel on 03/02/16.
//  Copyright © 2016 REACT. All rights reserved.
//

#import <UIKit/UIKit.h>

//  Import the Padoc interface
#import "MHPadoc.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//  Set the padoc object
- (void)setPadocObject:(MHPadoc *)padoc;


@end

