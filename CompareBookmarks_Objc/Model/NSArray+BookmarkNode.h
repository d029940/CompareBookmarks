//
//  NSArray+BookmarkNode.h
//  CompareBookmarks_Objc
//
//  Created by Manfred on 07.12.18.
//  Copyright © 2018 Manfred Kern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (BookmarkNode)

- (NSMutableArray<BookmarkNode *> *)sortBookmarkNodes;

@end

NS_ASSUME_NONNULL_END
