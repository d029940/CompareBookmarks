//
//  AppController.m
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 01.01.17.
//  Copyright © 2017 Manfred Kern. All rights reserved.
//

#import "AppDelegate.h"
#import "AppController.h"
#import "MainWindowController.h"

static Bookmarks *bookmarks = nil;

@interface AppController()

@property IBOutlet NSWindow *aboutSheet;

@end

#pragma mark -

@implementation AppController


- (instancetype)init
{
	self = [super init];
	if (self) {
		// Initialize the model
		if (bookmarks == nil)
			bookmarks = [[Bookmarks alloc] init];
	}
	return self;
}

#pragma mark -  Model
+ (Bookmarks *)bookmarks {
	return bookmarks;
}


#pragma mark - About Sheet

- (IBAction)closeAboutSheet:(NSButton *)sender {
	
	AppDelegate *appDel = NSApp.delegate;
	[appDel.mainWindowController.mainWindow endSheet:self.aboutSheet];
}

- (IBAction)showAboutSheet:(NSMenuItem *)sender {

	BOOL res;
	if (!self.aboutSheet) {
		res = [[NSBundle mainBundle] loadNibNamed:@"AboutSheet" owner:self topLevelObjects:nil];
	}
	
	AppDelegate *appDel = NSApp.delegate;
	
	[appDel.mainWindowController.mainWindow beginSheet:self.aboutSheet
              completionHandler:^(NSModalResponse returnCode) {}];

}


@end
