//
//  defaultsGoogle.m
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 23.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "Google.h"
#import "BookmarkNode.h"
#import "NSArray+BookmarkNode.h"
#import "OutlineViewController.h"	// Strange, but we need because it contains the top-level object of the model

# pragma mark - Constants

// default path to Google bookmarks location on Mac OSX
static NSString * const kRelativePathToBookmarks = @"/Library/Application Support/Google/Chrome/Default/";
static NSString * const kBookmarksFile = @"Bookmarks";

// Constants for elements of the Google Bookmark file
static NSString * const kGoogleUrl = @"url";
static NSString * const kGoogleType = @"type";
static NSString * const kGoogleName = @"name";
static NSString * const kGoogleFolder = @"folder";


@implementation Google

# pragma mark - Accessors

static NSString *_relativePathToBookmarks = nil;
+ (NSString const *)relativePathToBookmarks {return kRelativePathToBookmarks; }

static NSString *_bookmarksFile = nil;
+ (NSString const *)bookmarksFile {return kBookmarksFile; }


#pragma mark - Reading Bookmark File

+ (NSMutableArray<BookmarkNode *> *)readFile:(NSURL *)url
{
	assert(url != nil);

	NSError *error = nil;
	
	NSInputStream *inputStream = [NSInputStream inputStreamWithURL:url];
	[inputStream open];
	// TODO: check streamError
	NSDictionary *topLevelDict = [NSJSONSerialization JSONObjectWithStream:inputStream options:NSJSONReadingMutableContainers error:&error];
	if (error != nil) {
		// TODO: better error handling
		NSLog(@"Error opening Google Bookmarks file %@\rDescription: %@",
			  url.absoluteString,
			  error.localizedDescription);
		[inputStream close];
		return nil;
	}
    [inputStream class];
	
	// Read bookmarks file & init internal bookmarks model
	
	NSDictionary *roots = topLevelDict[@"roots"];
	NSDictionary *bookmark_bar = roots[@"bookmark_bar"];
	NSDictionary *other = roots[@"other"];
	
	// read Bookmarks Bar
	NSMutableArray<BookmarkNode *> *bookmarkNodes = [[NSMutableArray<BookmarkNode *> alloc] init];
    [bookmarkNodes addObject:[self readNode:bookmark_bar parent:nil]];
	bookmarkNodes.lastObject.name = MKEBookmarkBar;
	
	// read Others
	[bookmarkNodes addObject:[self readNode:other parent:nil]];
	bookmarkNodes.lastObject.name = MKEOtherBookmarks;

	return bookmarkNodes;
}


#pragma mark - Helper

+ (BookmarkNode*)readNode:(id)node parent:(BookmarkNode*)parent
{
    if (node == nil) return nil;
    
	// instead of asking for NSDictionary, NSArray... func "object_getClass(node)" can be used
	if ([node isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = node;
		
		NSString *type = dict[kGoogleType];
		NSString *name = dict[kGoogleName];
		
		
		if ([type isEqualToString:kGoogleFolder]) {
			// Add Bookmark Folder
			BookmarkNode* bookmarknode = [[BookmarkNode alloc] initWithName:name
																	   type:MKEBookmarkNodeTypeFolder
																		url:nil
																	 parent:parent];
			
			// Add children of bookmark folder & sort it
			NSArray *folders = dict[@"children"];
			for (id folder in folders) {
				[bookmarknode addChild:[self readNode:folder parent:bookmarknode]];
			}
			
			// Sort the child bookmark nodes
            bookmarknode.children = [bookmarknode.children sortBookmarkNodes];

			return bookmarknode;
			
		} else if ([type isEqualToString:kGoogleUrl]) {
			NSString *url = dict[kGoogleUrl];
			BookmarkNode *bookmarkNode = [[BookmarkNode alloc] initWithName:name
																	   type:MKEBookmarkNodeTypeUrl
																		url:url
																	 parent:parent];
			return bookmarkNode;
		} else {
			NSLog(@"Type = %@", type);
		}
		
	} else if ([node isKindOfClass:[NSArray class]]) {
		NSLog(@"Array");
	} else if ([node isKindOfClass:[NSString class]]) {
		NSLog(@"String");
	} else if ([node isKindOfClass:[NSData class]]) {
		NSLog(@"Data");
	} else if ([node isKindOfClass:[NSNumber class]]) {
		NSLog(@"Number");
	}
	return nil;
}

@end
