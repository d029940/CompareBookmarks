//
//  MainWindowController.m
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 23.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "MainWindowController.h"
#import "AppController.h"
#import "Browsers.h"
#import "UserPreferences.h"

@interface MainWindowController ()

// Need properties for binding (KVC)
@property (nonatomic) TSupportedBrowser leftBrowser;
@property (nonatomic) TSupportedBrowser rightBrowser;

#pragma mark - Outlets

@property (weak) IBOutlet NSPopUpButton *leftBrowserPopUp;
@property (weak) IBOutlet NSPopUpButton *rightBrowserPopUp;

// link to bookmarks for outline views on the left & right
@property (weak) IBOutlet NSOutlineView *leftOutlineView;
@property (weak) IBOutlet NSOutlineView *rightOutlineView;

// labels indicating how many bookmarks exist only in the left or only in the right browser
@property (weak) IBOutlet NSTextField *leftLabel;
@property (weak) IBOutlet NSTextField *rightLabel;
// and the stepper to step thru the bookmarks
@property (weak) IBOutlet NSStepper *leftStepper;
@property (weak) IBOutlet NSStepper *rightStepper;

@end

#pragma mark -

@implementation MainWindowController {
    // variables to detect if stepper up or down has been pushed
    NSUInteger leftLastStepperValue;
    NSUInteger rightLastStepperValue;
}

#pragma mark - Windows Startup

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Get user preferences
    UserPreferences* userPref = [UserPreferences userPref];
    // determine available browsers
    TSupportedBrowsers availableBrowsers = [userPref browsers];
    
    // Update NSPopup with available browsers
    [self.leftBrowserPopUp removeAllItems];
    [self.rightBrowserPopUp removeAllItems];
    [self.leftBrowserPopUp addItemsWithTitles:availableBrowsers];
    [self.rightBrowserPopUp addItemsWithTitles:availableBrowsers];
    for (int i = 0; i < availableBrowsers.count; i++) {
        self.leftBrowserPopUp.itemArray[i].tag = i;
        self.rightBrowserPopUp.itemArray[i].tag = i;
    }
    
    // get current selected browsers from user preferences and set popup controls respectively
    self.leftBrowser = userPref.leftBrowser;
    self.rightBrowser = userPref.rightBrowser;
    
    [self.leftBrowserPopUp selectItemWithTitle:self.leftBrowser];
    [self.rightBrowserPopUp selectItemWithTitle:self.rightBrowser];
    
    // Read 1st time bookmarks for the browsers
    
    NSURL *url = nil;
    
    url = userPref.leftAbsBookmarkPath;
    if (url == nil)
        return;
    [AppController.bookmarks readBookmarksFrom:url ofBrowser:self.leftBrowser forLeftOrRight:kLeft];
    [self.leftOutlineView reloadData];
    
    url = userPref.rightAbsBookmarkPath;
    if (url == nil)
        return;
    [AppController.bookmarks readBookmarksFrom:url ofBrowser:self.rightBrowser forLeftOrRight:kRight];
    [self.rightOutlineView reloadData];
}

#pragma mark - Actions

/**
 Select the browser based on the the selection with the popup button. 
 The popup button also helps to identify whether the left or the right browser changed. 
 The corresponding data of the last comparision is cleared.

 @param sender sender of the popup button
 */
- (IBAction)selectBrowser:(NSPopUpButton*)sender
{
    // When new browser is selected or on startup
    // - set user preferences
    // - read bookmarks of the selected browser
    // - reset compare results, if any

    UserPreferences *userPref = [UserPreferences userPref];
	LeftOrRightBrowser leftOrRight = sender.tag;
    TSupportedBrowser selectedBrowser = [userPref.browsers objectAtIndex:sender.selectedTag];
    [userPref setLeftOrRightBrowser:leftOrRight to:selectedBrowser];
    Bookmarks *bookmarks = AppController.bookmarks;
    
    // Clear bookmarks & reload outline view
	if (leftOrRight == kLeft) { // left Browser
		[bookmarks.leftBookmarks removeAllObjects];
        [bookmarks readBookmarksFrom:userPref.leftAbsBookmarkPath ofBrowser:selectedBrowser forLeftOrRight:kLeft];
	} else {
		[bookmarks.rightBookmarks removeAllObjects];
        [bookmarks readBookmarksFrom:userPref.rightAbsBookmarkPath ofBrowser:selectedBrowser forLeftOrRight:kRight];
	}
    
    // Reset compare results, if any - Set all bookmark nodes to "undefined" as if a comparison never happened
    [bookmarks resetCompareResults];
    [self resetUIControlsOfComparison];
    
    // refresh UI
    [self.leftOutlineView reloadData];
    [self.rightOutlineView reloadData];
    
    
}

/**
 Open the selected browser identified by the button and read the bookmarks

 @param sender sender of the button
 */
- (IBAction)openBrowser:(NSButton*)sender {
    
    // Identify whether left of right browser "open button" has been pushed.
    // Alternative 1: create an outlet per button and check sender vs outlet
    // Alternative 2: create seperate actions for each button
    
    UserPreferences* userPref = [UserPreferences userPref];
    LeftOrRightBrowser leftRightBrowser = sender.tag;
    TSupportedBrowser browser;
    
    // Determine if left or right browser on window is used
    if (leftRightBrowser == kLeft) {
        browser = userPref.browsers[(self.leftBrowserPopUp).selectedTag];
    } else {
        browser = userPref.browsers[(self.rightBrowserPopUp).selectedTag];
    }

    
    // Read url of the selected browser and store it for later use
    
    NSURL *url = [self openFileForBrowser:leftRightBrowser];
	
	if (url == nil)
		return;

	if (leftRightBrowser == kLeft) {
		userPref.leftAbsBookmarkPath = url;
		[AppController.bookmarks readBookmarksFrom:url ofBrowser:browser forLeftOrRight:leftRightBrowser];
		[self.leftOutlineView reloadData];
	} else {
		userPref.rightAbsBookmarkPath = url;
		[AppController.bookmarks readBookmarksFrom:url ofBrowser:browser forLeftOrRight:leftRightBrowser];
		[self.rightOutlineView reloadData];
	}

}

/**
 Compare bookmarks of the left and right browser. Mark those bookmarks which exist only in onw browser.

 @param sender Compare button
 */
- (IBAction)compareBookmarks:(NSButton *)sender {
	
	Bookmarks *bookmarks = [AppController bookmarks];

	// Set all bookmark nodes to "undefined" as if a comparison never happened and reset related UI controls
    [bookmarks resetCompareResults];
    [self resetUIControlsOfComparison];
	
	[bookmarks compareBookmarksLeft:bookmarks.leftBookmarks withRight:bookmarks.rightBookmarks];
	
	// After comparison set left and right label indicating only bookmarks (-folder) in browser
    self.leftLabel.integerValue = [AppController bookmarks].leftOnlyBookmarks.count;
    self.rightLabel.integerValue = [AppController bookmarks].rightOnlyBookmarks.count;
    self.leftStepper.maxValue = [AppController bookmarks].leftOnlyBookmarks.count;
    self.rightStepper.maxValue = [AppController bookmarks].rightOnlyBookmarks.count;
	
	// reload outline view to reflect the differences
	[self.leftOutlineView reloadData];
	[self.rightOutlineView reloadData];
	[self.rightOutlineView expandItem:nil expandChildren:YES];
	[self.leftOutlineView expandItem:nil expandChildren:YES];
}
- (IBAction)refresh:(NSButton *)sender {
    
    // Read 1st time bookmarks for the browsers
    
    TSupportedBrowser browser;
    NSURL *url = nil;
    UserPreferences* userPref = [UserPreferences userPref];
    Bookmarks *bookmarks = AppController.bookmarks;
    
    // Reset compare results, if any - Set all bookmark nodes to "undefined" as if a comparison never happened
    [bookmarks resetCompareResults];
    [self resetUIControlsOfComparison];
    
    browser = userPref.browsers[(self.leftBrowserPopUp).selectedTag];
    url = userPref.leftAbsBookmarkPath;
    if (url == nil)
        return;
    [bookmarks readBookmarksFrom:url ofBrowser:browser forLeftOrRight:kLeft];
    [self.leftOutlineView reloadData];
    
    browser = userPref.browsers[(self.rightBrowserPopUp).selectedTag];
    url = userPref.rightAbsBookmarkPath;
    if (url == nil)
        return;
    [bookmarks readBookmarksFrom:url ofBrowser:browser forLeftOrRight:kRight];
    [self.rightOutlineView reloadData];

}

/**
 Jumps to the next bookmark (-folder) that exists only in the browser (on the left or the right)
 The bookmark (-folder) is selected and the view is scrolled so that the selected bookmark (-folder) is shown
 in the middle of the view
 
 Prerequisite: Comparison run has been executed before

 @param sender tepper for left or right browser
 */
- (IBAction)stepToBookmark:(NSStepper *)sender
{
    NSArray<BookmarkNode *> *bookMarkNodes;
    NSOutlineView *outlineView;
    NSTextField *label;
    BOOL stepperPressedUp;  // if up or down of the stepper has been pressed
    
    if (sender == self.leftStepper) {
        outlineView = self.leftOutlineView;
        label = self.leftLabel;
        stepperPressedUp = sender.integerValue > leftLastStepperValue ? YES : NO;
        leftLastStepperValue = sender.integerValue;
        
        // get bookmarks (-folder) which exist only in this browser
        bookMarkNodes = [AppController bookmarks].leftOnlyBookmarks;
        // Reset if there is no comparison result
        if (bookMarkNodes.count == 0) {
            self.leftLabel.integerValue = 0;
            return;
        }
        
    } else {
        outlineView = self.rightOutlineView;
        label = self.rightLabel;
        stepperPressedUp = sender.integerValue > rightLastStepperValue ? YES : NO;
        rightLastStepperValue = sender.integerValue;
        bookMarkNodes = [AppController bookmarks].rightOnlyBookmarks;
        // Reset if there is no comparison result
        if (bookMarkNodes.count == 0) {
            self.rightLabel.integerValue = 0;
            return;
        }
    }
    
    // set focus on this outline view
    [outlineView.window makeFirstResponder:outlineView];
    
    
    NSInteger maxBookmarkNodes = bookMarkNodes.count;
    NSInteger index = sender.integerValue;
    
    // Update label
    label.stringValue = [NSString stringWithFormat:@"%ld of %ld", index, maxBookmarkNodes];
    
    // Do nothing if there are no bookmarks or if stepper has gone below the first bookmark
    if (maxBookmarkNodes < 1) return;
    if (index <= 0) {
        sender.integerValue = 0;
        return;
    }
    
    // restrict index to the max of bookmarks
    if (index > maxBookmarkNodes) index = maxBookmarkNodes;    // Should not happen
    
    if (0 < index && index <= maxBookmarkNodes) {
        BookmarkNode *bookmarkNode = bookMarkNodes[index - 1];
        NSInteger row = [outlineView rowForItem:bookmarkNode];
        
        if (row >= 0) {
            // Select row
            NSIndexSet *is = [NSIndexSet indexSetWithIndex:row];
            [outlineView selectRowIndexes:is byExtendingSelection:NO];
            
            // Scroll the view, so that the selected row is visible and centered
            NSRect visibleRect = outlineView.visibleRect;
            NSRange visibleRange = [outlineView rowsInRect:visibleRect];
            NSUInteger offset = visibleRange.length / 2;
            if (!stepperPressedUp) // if stepper is pressed up then a positive offset is needed, otherwise a negative offset
                offset = -offset;
            NSInteger scrollPos = row + offset;
            
            // Adapt if it would be out of visible range or out of the limits of the outline view
            if (scrollPos >= outlineView.numberOfRows) {
                scrollPos = outlineView.numberOfRows - 1;
            } else if (scrollPos < visibleRange.length) {
                scrollPos = row;
            }
            [outlineView scrollRowToVisible:scrollPos];
        }
    }

}

#pragma mark - Helpers

/**
 reset all UI Controls which are set by a comparison run
 */
- (void)resetUIControlsOfComparison
{
    // Left side browser
    self.leftLabel.stringValue = @"";
    self.leftStepper.minValue = 0;
    self.leftStepper.maxValue = AppController.bookmarks.leftOnlyBookmarks.count;
    self.leftStepper.integerValue = 0;
    leftLastStepperValue = 0;
    
    // Right side browser
    self.rightLabel.stringValue = @"";
    self.rightStepper.minValue = 0;
    self.rightStepper.maxValue = AppController.bookmarks.rightOnlyBookmarks.count;
    self.rightStepper.integerValue = 0;
    rightLastStepperValue = 0;
}


/**
 Show a file open dislog for the selected browser to select the bookmark file, i.e. retrieve the URL

 @param browser the browser for which to ask for the bookmark file
 @return URL of the selected bookmark file
 */
- (NSURL*)openFileForBrowser:(LeftOrRightBrowser)browser
{
    NSURL *url = nil;
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    
    if (browser == kLeft)
        url = [NSURL fileURLWithPath:[UserPreferences userPref].leftRelativePathToBookmarks];
    else
        url = [NSURL fileURLWithPath:[UserPreferences userPref].rightRelativePathToBookmarks];
    
    // TODO: translation
    openDlg.title = @"Select Bookmarks File";
    openDlg.nameFieldLabel = @"Bookmarks";
    openDlg.directoryURL = url;
    openDlg.allowsMultipleSelection = NO;
    openDlg.canChooseDirectories = NO;
    openDlg.canCreateDirectories = NO;
    openDlg.canChooseFiles = YES;
    
    // Open, read and process bookmarks file
	
//	__block NSURL *returnedURL = nil;
//    [openDlg beginSheetModalForWindow:_mainWindow
//                    completionHandler:^(NSInteger result) {
//                        if (result == NSFileHandlingPanelOKButton) {
//							returnedURL = openDlg.URL;
//                        }
//                    }];
//	NSLog(@"Returned URL = %@", returnedURL);
//	return returnedURL;
	
    if ([openDlg runModal] == NSModalResponseOK) {
        return openDlg.URL;
    } else {
        return nil;
    }
	
}


@end
