//
//  AppDelegate.m
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 23.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

- (instancetype)init
{
	self = [super init];
	if (self) {
		// Setup AppController
		_appController = [[AppController alloc] init];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Create a window controller
	MainWindowController *mainWindowController =
 		[[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
	// set the property to point to the window controller
	self.mainWindowController = mainWindowController;

	// Put the windows of the main window controller on the screen
	[mainWindowController showWindow:self];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
