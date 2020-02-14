//
//  BookmarkNode.h
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 25.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

/**
 Represents a bookmarknode. A bookmark node can either be a bookmark having a URL or a folder 
 containing other bookmark nodes.
 */

@import Foundation;
// #import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------------------------------

#pragma mark - Constants

typedef NS_ENUM(NSInteger, BookmarkNodeType) {
    MKEBookmarkNodeTypeFolder,
    MKEBookmarkNodeTypeUrl
};

// Typedef for the result of bookmark comparison
typedef NS_ENUM(NSInteger, CompareResultType) {
	MKECompareResultUndefined,	// no comparison run yet
	MKECompareResultOnly,			// Only one browser contains bookmark
	MKECompareResultBoth			// Both browsers contain bookmark
};

FOUNDATION_EXPORT NSString *const MKEBookmarkBar;
FOUNDATION_EXPORT NSString *const MKEOtherBookmarks;

// ----------------------------------------------------------------------------------------------------

#pragma mark - class definiton

/**
 Represents a bookmark node, i.e. a bookmark or a bookmark folder
 */
@interface BookmarkNode : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) BookmarkNodeType type;        // either be a bookmark (url) or a bookmark folder
@property (nonatomic) NSString *url;                // url if it is a bookmark

@property (nonatomic) CompareResultType compareResult;    // if a comparison is run, a bookmark node is marked as ONLY if it is only known in one browser, otherwise BOTH

@property (nonatomic) NSMutableArray<BookmarkNode *> *children; // Sorted by the calling function before "addChild" is called
@property (weak) BookmarkNode *parent;

/**
 Initializes a Bookmark node.

 @param name: Name of the bookmark node
 @param type: A bookmark node can be aa bookmark (url) or a bookmark folder
 @param url: url of the bookmark, if it is a bookmark
 @param parent Bookmrk nodes are stored in a tree structure. This is a link to the parent node
 @return: id / instance of the inintialized bookmark node
 */
- (instancetype)initWithName:(NSString *)name
						type:(BookmarkNodeType)type
						 url:(NSString *)url
					  parent:(BookmarkNode*)parent;

- (instancetype)initWithName:(NSString *)name
						type:(BookmarkNodeType)type
						 url:(NSString *)url
			   compareResult:(CompareResultType)compareResult
					  parent:(BookmarkNode*)parent NS_DESIGNATED_INITIALIZER;


/**
 Copy a bookmark node - but without children (shallow copy)

 @param parent a bookmark node, which should be the parent of the new created and copied bookmark node
 @return copied Bookmark node
 */
- (BookmarkNode *)copy:(BookmarkNode *)parent;

// ----------------------------------------------------------------------------------------------------

#pragma mark - sorting & comparing

+ (NSArray *)sortDescriptors;
//@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray<BookmarkNode *> *sortChildBookmarkNodes;

- (NSComparisonResult)compare:(BookmarkNode *)toCompare;

#pragma mark - other methods

/**
 Add a bookmark node as a child

 @param bookmarkNode bookmark node to be added as a child
 */
- (void)addChild:(BookmarkNode *)bookmarkNode;


@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *description;

@end




