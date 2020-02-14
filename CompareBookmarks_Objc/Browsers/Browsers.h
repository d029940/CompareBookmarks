//
//  Browsers.h
//  CompareBookmarks_Objc
//
//  Created by Kern, Manfred on 29/11/2016.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LeftOrRightBrowser) {
	kLeft,
	kRight
};

typedef NSString * TSupportedBrowser;
typedef NSArray<NSString *> *TSupportedBrowsers;

@interface Browsers : NSObject

// Currently the browsers Safari, Google Chrome and Firefox are supported, if installed
@property (class, readonly, nonatomic, nonnull) TSupportedBrowser kGoogle;
@property (class, readonly, nonatomic, nonnull) TSupportedBrowser kSafari;
@property (class, readonly, nonatomic, nonnull) TSupportedBrowser kFirefox;

// Should search for installed apps should only look at the top level application dirs
// or should it it descend recursively the sub dirs.
@property (class) BOOL deepSearchAppDirs;

@property ( readonly, nonatomic) TSupportedBrowsers _Nonnull  supportedBrowsers;
@property (readonly, nonatomic) TSupportedBrowsers _Nullable availableBrowsers;

/**
 sharedInstance: singleton for this class
 */
+ (Browsers *_Nonnull)sharedInstance;

@end
