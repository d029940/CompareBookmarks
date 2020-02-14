//
//  Bookmarks.h
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 04.12.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Browsers.h"
#import "BookmarkNode.h"

/**
 The class Bookmarks represents the model. It is a singleton
 It contains the array of bookmark nodes for the left and right browser selected in the UI
 Reads the bookmarks of the selected browsers and compares them
 */
@interface Bookmarks : NSObject

/**
 Bookmarks are stored in an array - Properties holding left bookmarks for outline views
 */
@property (nonatomic) NSMutableArray<BookmarkNode *> *leftBookmarks;
/**
 Bookmarks are stored in an array - Properties holding left bookmarks for outline views
 */
@property (nonatomic) NSMutableArray<BookmarkNode *> *rightBookmarks;

/**
 Bookmarks which exist only in the left browser
 */
@property (nonatomic) NSMutableArray<BookmarkNode *> *leftOnlyBookmarks;
/**
 Bookmarks which exist only in the right browser
 */
@property (nonatomic) NSMutableArray<BookmarkNode *> *rightOnlyBookmarks;


/**
 Creates a singleton

 @return Returns the singleton
 */
+ (Bookmarks *)sharedBookmarks;


/**
 Reads the bookmark file of the selected browsers
 The representation of the bookmark nodes will be saved either for the left or right browser (supposed to be selected in the UI

 @param file Url of the file (full path)
 @param browserType The browser selected (Safari, Google, Firefox, ...)
 @param leftOrRight Location to be saved internally (left or right as supposed to be selected by the UI
 */
- (void)readBookmarksFrom:(NSURL *)file ofBrowser:(TSupportedBrowser)browserType forLeftOrRight:(LeftOrRightBrowser)leftOrRight;

/**
 Resets the information in each bookmark node saved by last comparison
 */
- (void)resetCompareResults;

/**
 Compares the selected bookmarks (the internal structures of Bookmark nodes)

 @param left internal represenatation of the bookmarks on the left
 @param right internal represenatation of the bookmarks on the right
 */
- (void)compareBookmarksLeft:(NSMutableArray<BookmarkNode *> *)left withRight:(NSMutableArray<BookmarkNode *> *)right;

@end
