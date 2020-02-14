//
//  UserPreferences.h
//  CompareBookmarks_Objc
//
//  Created by Kern, Manfred on 30/11/2016.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Browsers.h"

@interface UserPreferences : NSObject

// All installed and supported browsers
@property TSupportedBrowsers browsers;

// the bookmarks of two browsers are compared. Hence one browser is named "left browser", the other "right browser"
@property TSupportedBrowser leftBrowser;
@property TSupportedBrowser rightBrowser;

// path and file information of the browsers to be compared
@property (copy) NSString *leftRelativePathToBookmarks;
@property (copy) NSString *rightRelativePathToBookmarks;
@property (copy) NSString *lefttBoookmarksFile;
@property (copy) NSString *rightBoookmarksFile;


// Current path to bookmarks file
@property NSURL *leftAbsBookmarkPath;
@property NSURL *rightAbsBookmarkPath;

+ (UserPreferences *) userPref;

- (void)setLeftOrRightBrowser:(LeftOrRightBrowser)leftOrRight to:(TSupportedBrowser)browser;

@end
