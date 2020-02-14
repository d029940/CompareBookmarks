//
//  UserPreferences.m
//  CompareBookmarks_Objc
//
//  Created by Kern, Manfred on 30/11/2016.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "UserPreferences.h"
#import "Safari.h"
#import "Google.h"
#import "Firefox.h"

static UserPreferences *userPref = nil;

@implementation UserPreferences

#pragma - Initializing

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // determine available browsers
        _browsers = [[Browsers sharedInstance] availableBrowsers];
        if (_browsers.count < 2)
            // Nothing to compare
            return nil;

        // TODO: Set default browsers by reading user preferences from file
        _leftBrowser =  [Browsers kGoogle];
        _rightBrowser = [Browsers kSafari];
        
        NSString *homeDirectory = NSHomeDirectory();
        
        _leftRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", homeDirectory, Google.relativePathToBookmarks];
        _lefttBoookmarksFile = Google.bookmarksFile;
        _leftAbsBookmarkPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",
                                                       _leftRelativePathToBookmarks, _lefttBoookmarksFile]];
        
        _rightRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", homeDirectory, Safari.relativePathToBookmarks];
        _rightBoookmarksFile = Safari.bookmarksFile;
        _rightAbsBookmarkPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",
                                                       _rightRelativePathToBookmarks, _rightBoookmarksFile]];
        
    }
    return self;
}

+ (UserPreferences *)userPref {
    if (userPref == nil)
        userPref = [[UserPreferences alloc] init];
    return userPref;
}

#pragma - methods

/**
 Depending on the parameters sets the left or the right browser to the indicated browser

 @param leftOrRight indicates if the left or the right browser should be set
 @param suppBrowser indicates which browser shuold be used
 */
- (void)setLeftOrRightBrowser:(LeftOrRightBrowser)leftOrRight to:(TSupportedBrowser)browser
{
    if (leftOrRight == kLeft) { // left Browser
        
        if (browser == [Browsers kGoogle]) {
            self.leftBrowser = [Browsers kGoogle];
            self.leftRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),
                                                [Google relativePathToBookmarks]];
            self.lefttBoookmarksFile = [Google bookmarksFile];
        } else if (browser == [Browsers kSafari]) {
            self.leftBrowser = [Browsers kSafari];
            self.leftRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),
                                                [Safari relativePathToBookmarks]];
            self.lefttBoookmarksFile = [Safari bookmarksFile];
        } else if (browser == [Browsers kFirefox]) {
            self.leftBrowser = [Browsers kFirefox];
            self.leftRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),
                                                [Firefox relativePathToBookmarks]];
        } else {
            NSLog(@"Not implemented yet!");
            return;
        }
        
		self.leftAbsBookmarkPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",
														   self.leftRelativePathToBookmarks,
														   self.lefttBoookmarksFile]];
    } else {    // right Browser
        if (browser == [Browsers kGoogle]) {
            self.rightBrowser = [Browsers kGoogle];
            self.rightRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),
                                                 [Google relativePathToBookmarks]];
            self.rightBoookmarksFile = [Google bookmarksFile];
        } else if (browser == [Browsers kSafari]) {
            self.rightBrowser = [Browsers kSafari];
            self.rightRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),
                                                 [Safari relativePathToBookmarks]];
            self.rightBoookmarksFile = [Safari bookmarksFile];
        } else if (browser == [Browsers kFirefox]) {
            self.rightBrowser = [Browsers kFirefox];
            self.rightRelativePathToBookmarks = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),
                                                [Firefox relativePathToBookmarks]];
        } else {
            NSLog(@"Not implemented yet!");
            return;
        }
            
		self.rightAbsBookmarkPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",
															self.rightRelativePathToBookmarks,
															self.rightBoookmarksFile]];
		
    }
}

@end
