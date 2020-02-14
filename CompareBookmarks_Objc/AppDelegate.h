//
//  AppDelegate.h
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 23.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"
#include "MainWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property AppController *appController;
@property (strong, nonatomic) MainWindowController *mainWindowController;

@end

