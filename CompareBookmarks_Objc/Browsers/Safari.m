//
//  Safari.m
//  CompareBookmarks_Objc
//
//  Created by Kern, Manfred on 30/11/2016.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "Safari.h"
#import "NSArray+BookmarkNode.h"

// default path to Safari bookmarks location on Mac OSX
static NSString const * kRelativePathToBookmarks = @"/Library/Safari/";
static NSString const * kBookmarksFile = @"Bookmarks.plist";


@implementation Safari


//---------------------------------------------------------------------------
# pragma mark - Accessors

static NSString *_relativePathToBookmarks = nil;
+ (NSString const *)relativePathToBookmarks {return kRelativePathToBookmarks; }

static NSString *_bookmarksFile = nil;
+ (NSString const *)bookmarksFile {return kBookmarksFile; }


//---------------------------------------------------------------------------
# pragma MARK: Reading Bookmark File

/**
 Reads Safari bookmark list and returns them as an array of bookmark nodes.

 @param url url of bookmarks file
 @return array of bookmark nodes, which is empty if there was an error
 */
+ (NSMutableArray<BookmarkNode *> *) readFile:(NSURL *)url {
    
    // Create an empty Browser bookmarks data structure
    NSMutableArray<BookmarkNode *> *bookmarkNodes = [[NSMutableArray <BookmarkNode *> alloc] init];
	NSMutableArray<BookmarkNode *> *returnBookmarkNodes = bookmarkNodes;
    
    // Read bookmark file (Safari bookmarks are stored in a plist
    NSError *error;
    NSDictionary *bookmarksDic = [NSDictionary dictionaryWithContentsOfURL:url error:&error];
    if (bookmarksDic == nil) {
        NSLog(@"Error reading Safari Bookmark file\n%@", [error description]);
        return nil;
    }
        
    NSArray *children = bookmarksDic[@"Children"];
    
    // read Bookmarks Bar
    
    for (NSDictionary *tmpDic in children) {
        
        // look only for bookmark folders
        if (![(NSString *)(tmpDic[@"WebBookmarkType"]) isEqualToString:@"WebBookmarkTypeList"])
             continue;
		
        // Check if Bookmarks bar
        if ([(NSString *)(tmpDic[@"Title"]) isEqualToString:@"BookmarksBar"]) {
            // All subnodes belong to Bookmarks bar
			BookmarkNode *tmpBookmarkNode = [self readNode:tmpDic parent:nil];
			if (tmpBookmarkNode) {
				[bookmarkNodes addObject:tmpBookmarkNode];
				bookmarkNodes.lastObject.name = MKEBookmarkBar;
			}
        } else {
            // process all other bookmark folders and bookmarks
            if ([(NSString *)(tmpDic[@"Title"]) isEqualToString:@"BookmarksMenu"]) {
                // BookmarksMenu in the Safari plist itself does not have any children
				// hence: Create a bookmarkNode for the Bookmarks menu
				BookmarkNode *bookmarkMenu = [[BookmarkNode alloc] initWithName:MKEOtherBookmarks
																		type:MKEBookmarkNodeTypeFolder
																		url:nil
																		parent:nil];
				[bookmarkNodes addObject:bookmarkMenu];
				bookmarkNodes = bookmarkMenu.children;
				continue;
            }
			BookmarkNode *tmpBookmarkNode = [self readNode:tmpDic parent:nil];
			if (tmpBookmarkNode)	[bookmarkNodes addObject:tmpBookmarkNode];
        }
    }
    
    // NSLog(@"Safari: %@", returnBookmarkNodes);
	
	/* Attention: All bookmarks in the Bookmark Bar are sorted (since there is a standalone node for the Bookmark Bar
	 * The Bookmarks Menu node is itself empty and all bookmark nodes follewing belong logically to the Bookmarks Menu. 
	 * They have been added in the same sequence as they were read. So they are not sorted. Sort them now!
	 */
	
	BookmarkNode *bookmarkMenu = returnBookmarkNodes.lastObject;
	bookmarkMenu.children = [bookmarkMenu.children sortBookmarkNodes];

    return returnBookmarkNodes;
}


#pragma mark - Helper

/**
 Read Node recursively (hierachally) and convert them to BookmarkNode

 @param node Starting bookmark node (as a Dictionary)
 @param parent Bookmarknode which should be the parent of the nodes to be read
 @return bookmark node under which all the subordinated bookmarkn nodes are located
 */
+ (BookmarkNode*)readNode:(NSDictionary*)node parent:(BookmarkNode*)parent {
    
    if (node == nil) return nil;
    
    NSString *webBookMarkType = node[@"WebBookmarkType"];
    
    if ([webBookMarkType isEqualToString:@"WebBookmarkTypeList"]) {
        
        // Bookmark folders
        NSString *title = node[@"Title"];
		
		// Skip Reading List
		if ([title compare:@"com.apple.ReadingList"] == NSOrderedSame) return nil;

        // Add Bookmark Folder
        BookmarkNode* bookmarkNode = [[BookmarkNode alloc] initWithName:title
                                                                   type:MKEBookmarkNodeTypeFolder
                                                                    url:nil
                                                                 parent:parent];
        
        // Add children of bookmark folder & sort it
        NSArray *folders = node[@"Children"];
        
        for (id folder in folders) {
            // BookmarksMenu is of type WebBookmarkTypeList, but (may) has no children
            BookmarkNode *tmpNode = [self readNode:folder parent:bookmarkNode];
            if (tmpNode) {
                [bookmarkNode addChild:tmpNode];
            }
        }
        // Sort the child bookmark nodes
        bookmarkNode.children = [bookmarkNode.children sortBookmarkNodes];
        

        return bookmarkNode;
        
    } else if ([webBookMarkType isEqualToString:@"WebBookmarkTypeLeaf"]) {
        
        // Bookmark (leaf)
        NSDictionary *uriDict = node[@"URIDictionary"];
        if (uriDict == nil) return nil;
        
        NSString *url = node[@"URLString"];
        BookmarkNode *bookmarkNode = [[BookmarkNode alloc] initWithName: uriDict[@"title"]
                                                                   type:MKEBookmarkNodeTypeUrl
                                                                    url:url
                                                                 parent:parent];
        return bookmarkNode;
        
    } else {
        return nil;
    }
}


@end
