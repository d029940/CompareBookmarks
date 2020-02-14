//
//  AppController.h
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 01.01.17.
//  Copyright © 2017 Manfred Kern. All rights reserved.
//

// #import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Bookmarks.h"

/**
 The AppController contains all data and references to data which belong to the whole application, such as the reference to the model
 (It could also be put into the AppDelegate)
 */
@interface AppController : NSObject


// reference to the data model
@property Bookmarks *bookmarks;

+ (Bookmarks *)bookmarks;


@end
