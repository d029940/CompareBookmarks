//
//  Firefox.h
//  CompareBookmarks_Objc
//
//  Created by Manfred on 19.11.18.
//  Copyright © 2018 Manfred Kern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkNode.h"
#import "Bookmarks.h"

NS_ASSUME_NONNULL_BEGIN

@interface Firefox : NSObject

/**
 path to the Profiles directroy starting from the home directory
 (default installation: Library/Application Support/Firefox/Profiles)
 */
@property (nonatomic, nullable, class, readonly) NSString *relativePathToBookmarks;

/**
 filename of bookmarks file (default installation: places.sqlite)
 */
@property (nonatomic, class, readonly) NSString *bookmarksFile;

/**
 Reads the Firefox bookmark file and returns an array of bookmark nodes which are tree-like structured

 @param url url of Firefox bookmarks file
 @return array of bookmark nodes (a bookmark node represents a tree-like structure
 */
+ (nullable NSMutableArray<BookmarkNode *> *) readFile:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
