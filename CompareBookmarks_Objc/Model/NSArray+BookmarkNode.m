//
//  NSArray+BookmarkNode.m
//  CompareBookmarks_Objc
//
//  Created by Manfred on 07.12.18.
//  Copyright © 2018 Manfred Kern. All rights reserved.
//

#import "NSArray+BookmarkNode.h"

@implementation NSArray (BookmarkNode)

- (NSMutableArray<BookmarkNode *> *)sortBookmarkNodes
{
    return [NSMutableArray arrayWithArray:[self sortedArrayUsingDescriptors:[BookmarkNode sortDescriptors]]];
}

@end
