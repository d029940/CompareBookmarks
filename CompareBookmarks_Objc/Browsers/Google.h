//
//  defaultsGoogle.h
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 23.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkNode.h"
#import "Bookmarks.h"

@interface Google : NSObject


@property (nonatomic, class, readonly) NSString *relativePathToBookmarks;
@property (nonatomic, class, readonly) NSString *bookmarksFile;

+ (NSMutableArray<BookmarkNode *> *) readFile:(NSURL *)url;

@end
