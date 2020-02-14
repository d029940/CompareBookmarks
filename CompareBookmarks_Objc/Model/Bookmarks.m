//
//  Bookmarks.m
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 04.12.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "Bookmarks.h"
#import "Google.h"
#import "Safari.h"
#import "Firefox.h"

@implementation Bookmarks

#pragma mark - Initializer

+ (Bookmarks *)sharedBookmarks {
	{
		static Bookmarks *bookmarks;
		
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			bookmarks = [[Bookmarks alloc] init];
		});
		return bookmarks;
	}
}

- (instancetype)init
{
    self = [super init];
    if (self) {
		_leftBookmarks = [[NSMutableArray<BookmarkNode *> alloc] init];
		_rightBookmarks = [[NSMutableArray<BookmarkNode *> alloc] init];
		_leftOnlyBookmarks = [[NSMutableArray<BookmarkNode *> alloc] init];
		_rightOnlyBookmarks = [[NSMutableArray<BookmarkNode *> alloc] init];
	}
    return self;
}



#pragma mark - reading & comparing

- (void)readBookmarksFrom:(NSURL *)file ofBrowser:(TSupportedBrowser)browserType forLeftOrRight:(LeftOrRightBrowser)leftOrRight {
	
	if (file == nil)
		return;
	
	// Check which browser bookmarks should be read
    
    if (browserType == [Browsers kGoogle]) {
        if (leftOrRight == kLeft)
            self.leftBookmarks = [Google readFile:file];
        else
            self.rightBookmarks = [Google readFile:file];
    } else if (browserType == [Browsers kSafari]) {
        if (leftOrRight == kLeft)
            self.leftBookmarks = [Safari readFile:file];
        else
            self.rightBookmarks = [Safari readFile:file];
    } else if (browserType == [Browsers kFirefox]) {
        if (leftOrRight == kLeft)
            self.leftBookmarks = [Firefox readFile:file];
        else
            self.rightBookmarks = [Firefox readFile:file];
    } else {
        NSLog(@"Browser not supported!");
	}
    
    // reset compare results
    [self resetCompareResults:self.leftBookmarks];
    [self resetCompareResults:self.rightBookmarks];
	
}

/**
 Compare Bookmarks of two browsers
 
 @param left bookmarks of left browser
 @param right bookmarks of right browser
 */
- (void)compareBookmarksLeft:(NSMutableArray<BookmarkNode *> *)left withRight:(NSMutableArray<BookmarkNode *> *)right {
	
	NSUInteger leftIndex = 0;
	NSUInteger rightIndex = 0;
	
	
	// take the left browser as the leading browser
	while (leftIndex < left.count) {
		
		while (rightIndex < right.count) {
			NSComparisonResult result = [left[leftIndex] compare:right[rightIndex]];
			
			if (result == NSOrderedAscending) {
				left[leftIndex].compareResult = MKECompareResultOnly;
				[self.leftOnlyBookmarks addObject:left[leftIndex]];
				break;
			} else if (result == NSOrderedDescending) {
				right[rightIndex].compareResult = MKECompareResultOnly;
				[self.rightOnlyBookmarks addObject:right[rightIndex]];
				rightIndex++;
				continue;
			} else {
				// left bookmark equls right bookmark (name and type!)
				left[leftIndex].compareResult = MKECompareResultBoth;
				right[rightIndex].compareResult = MKECompareResultBoth;
				
				// Check if folders: Yes? compare children!
				if (left[leftIndex].type == MKEBookmarkNodeTypeFolder) {
					[self compareBookmarksLeft:left[leftIndex].children withRight:right[rightIndex].children];
				}
				rightIndex++;
				break;
			}
		}
		leftIndex++;
		
		if (rightIndex >= right.count && leftIndex < left.count) {
			// All bookmarks on the right are processed. The remaining bookmarks on the left exist only on the left browser
			left[leftIndex].compareResult = MKECompareResultOnly;
			[self.leftOnlyBookmarks addObject:left[leftIndex]];
		}
	}
	
	// Since the left browser was the leading browser there maybe some bookmarks for the right browser left over. These exist ONLY for the right browser.
	while (rightIndex < right.count) {
		right[rightIndex].compareResult = MKECompareResultOnly;
		[self.rightOnlyBookmarks addObject:right[rightIndex]];
		rightIndex++;
	}
}


/**
 resets compare results, if any, i.e. esat all BookmarkNodes to "undefined" as if a comparison has never run
 */
- (void)resetCompareResults
{
    // Set all bookmark nodes to "undefined" as if a comparison never happened
    [self resetCompareResults:self.leftBookmarks];
    [self resetCompareResults:self.rightBookmarks];
    
    // empty arrays with references to ONLY bookmarks
    [self.leftOnlyBookmarks removeAllObjects];
    [self.rightOnlyBookmarks removeAllObjects];
}

#pragma mark - Helper methods

/**
 Resat all BookmarkNodes to "undefined" starting wirth bookmaknodes and all descedants
 
 @param bookMarkNodes Nodes of bookmarks to descend
 */
- (void)resetCompareResults:(NSMutableArray<BookmarkNode *> *)bookMarkNodes
{
    
    for (BookmarkNode *bm in bookMarkNodes) {
        bm.compareResult = MKECompareResultUndefined;
        if (bm.children.count > 0)
            [self resetCompareResults:bm.children];
    }
}


@end
