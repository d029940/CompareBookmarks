//
//  BookmarkNode.m
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 25.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "BookmarkNode.h"

NSString *const MKEBookmarkBar = @"Bookmark Bar";
NSString *const MKEOtherBookmarks = @"Other Bookmarks";

@interface BookmarkNode ()

@property (nonatomic) NSDate *lastUpdate;

@end

@implementation BookmarkNode

// Sort descriptor for the childen property
static NSSortDescriptor *_nameDescriptor = nil;
static NSSortDescriptor *_typeDescriptor = nil;
static NSArray<NSSortDescriptor *> *_sortDescriptors = nil;

#pragma -- initializers and copy

/**
 Several init methods
 
 @return initialized bookmark node
 */
- (instancetype)init
{
	return [self initWithName:nil type:MKEBookmarkNodeTypeFolder url:nil compareResult:MKECompareResultUndefined parent:nil];
}

- (instancetype)initWithName:(NSString *)name
						type:(BookmarkNodeType)type
						 url:(NSString *)url
					  parent:(BookmarkNode*)parent;
{
	return [self initWithName:name
						 type:type
						  url:url
				compareResult:MKECompareResultUndefined
					   parent:parent];
}

- (instancetype)initWithName:(NSString *)name
                        type:(BookmarkNodeType)type
                         url:(NSString *)url
			compareResult:(CompareResultType)compareResult
                      parent:(BookmarkNode*)parent;
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _type = type;
        _url = url;
		_compareResult = compareResult;
        _parent = parent;
        _children = [NSMutableArray array];
        
        if (_sortDescriptors == nil) {
            _typeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
			_nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            _sortDescriptors = @[_typeDescriptor, _nameDescriptor];
        }
        
    }
    return self;
}

- (BookmarkNode *)copy:(BookmarkNode *)parent {
	BookmarkNode *new = [[BookmarkNode alloc]
						 initWithName:self.name type:self.type url:self.url compareResult:self.compareResult parent:parent];
	return new;
}

#pragma mark - Sorting

+ (NSArray<NSSortDescriptor *> *)sortDescriptors {
    return _sortDescriptors;
}

/**
 Sort bookmark nodes according to the sort descriptors

 @return sorted array of bookmark nodes
 */
//- (NSMutableArray<BookmarkNode *> *)sortChildBookmarkNodes {
//    NSArray<BookmarkNode *> *children = self.children;
//    return [NSMutableArray arrayWithArray:[children sortedArrayUsingDescriptors:[BookmarkNode sortDescriptors]]];
//}

/**
 Compares two bookmark nodes

 @param toCompare bookmark node to be compared against
 @return if bookmark nodes are of same type then depeding on lexical, case insensitive order, otherwise folder is comes before url
 */
- (NSComparisonResult)compare:(BookmarkNode *)toCompare {
	
	if (self.type == MKEBookmarkNodeTypeFolder && toCompare.type != MKEBookmarkNodeTypeFolder) {
		// Folder comes before urls (refer to sortDescriptors, which apply the same sequence of sorting)
		return NSOrderedAscending;
	}

	if (self.type != MKEBookmarkNodeTypeFolder && toCompare.type == MKEBookmarkNodeTypeFolder) {
		// Folder comes before urls (refer to sortDescriptors, which apply the same sequence of sorting)
		return NSOrderedDescending;
	}
	
	// Both are folder or both are urls
	NSComparisonResult result = [self.name caseInsensitiveCompare:toCompare.name];
	
	if (result == NSOrderedSame) {
		if (self.type != toCompare.type) {
			// Same Name, but one is folder and one is leaf (treat folder as < leaf)
			return self.type == MKEBookmarkNodeTypeFolder ? NSOrderedAscending : NSOrderedDescending;
		}
	}

	return result;
}


#pragma mark - Methods

- (void)addChild:(BookmarkNode *)bookmarkNode
{
    [self.children addObject:bookmarkNode];
}

#pragma mark - Helper

- (NSString *)description {
    NSMutableString *descriptionString = [[NSMutableString alloc] init];
    if (self.type == MKEBookmarkNodeTypeFolder)
        [descriptionString appendFormat:@">>> %@ %ld\r", self.name, (long)self.compareResult];
    else
        // [descriptionString appendFormat:@"    Name: %@ - URL: %@ \n", self.name, self.url];
        [descriptionString appendFormat:@"    Name: %@ %ld\r", self.name, self.compareResult];
    
    for (NSString* child in self.children) {
        [descriptionString appendString:child.description];
    }
    
    return descriptionString;
    
}

@end
