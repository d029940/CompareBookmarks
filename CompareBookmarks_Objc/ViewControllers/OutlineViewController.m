//
//  OutlineViewController.m
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 25.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "OutlineViewController.h"
#import "AppDelegate.h"

@interface OutlineViewController()

#pragma mark - Outlets

@property (weak) IBOutlet NSOutlineView *leftOutlineView;
@property (weak) IBOutlet NSOutlineView *rightOutlineView;

@property (nonatomic) Bookmarks *bookmarks;

@end

#pragma mark -

@implementation OutlineViewController

#pragma MARK - initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
		_bookmarks = [AppController bookmarks];
    }
    return self;
}

#pragma mark - Methods to populate the Outline view from NSOutlineViewDataSource protocol

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item)
		return [item children].count;
	
	if (outlineView == self.leftOutlineView)
		return self.bookmarks.leftBookmarks.count;
	else
		return self.bookmarks.rightBookmarks.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return !item ? YES : [item children].count != 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	
	if (item != nil) {
		// Check to see if it is a bookmark folder and return specific bookmark node
		BookmarkNode *bn = item;
		if (bn.type == MKEBookmarkNodeTypeFolder && (bn.children).count >0) {
			return (bn.children)[index];
		}
	}
	if (outlineView == self.leftOutlineView)
		// TODO: Check if index is in range
		return (self.bookmarks.leftBookmarks)[index];
	else
		return (self.bookmarks.rightBookmarks)[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if ([tableColumn.identifier isEqualToString:@"name"]) {
		return [item name];
	} else if ([tableColumn.identifier isEqualToString:@"url"]) {
		return [item url] ? [item url] : @"";
	} else {
		return @"";
	}
}

#pragma mark - Cosmetic functions - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSString *id = tableColumn.identifier;
	NSTableCellView *view = [outlineView makeViewWithIdentifier:id owner:self];
	
    view.textField.textColor = [NSColor textColor];
	
	if ([id isEqualToString:@"name"] && [item compareResult] == MKECompareResultOnly) {
		view.textField.textColor = [NSColor systemRedColor];
	}
	return view;

}


@end
