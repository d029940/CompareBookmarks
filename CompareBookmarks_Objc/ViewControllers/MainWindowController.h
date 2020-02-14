//
//  MainWindowController.h
//  CompareBookmarks_Objc
//
//  Created by Manfred Kern on 23.06.16.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OutlineViewController.h"

@interface MainWindowController : NSWindowController


// MARK: - Outlets

@property (strong) IBOutlet NSWindow *mainWindow;

// MARK: - Actions

- (IBAction)compareBookmarks:(NSButton *)sender;

@end

