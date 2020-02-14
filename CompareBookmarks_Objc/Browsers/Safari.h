//
//  Safari.h
//  CompareBookmarks_Objc
//
//  Created by Kern, Manfred on 30/11/2016.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkNode.h"


@interface Safari : NSObject

@property (nonatomic, class, readonly) NSString *relativePathToBookmarks;
@property (nonatomic, class, readonly) NSString *bookmarksFile;

+ (NSMutableArray<BookmarkNode *> *)  readFile:(NSURL *)url;

@end
