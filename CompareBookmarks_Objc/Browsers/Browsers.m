//
//  Browsers.m
//  CompareBookmarks_Objc
//
//  Created by Kern, Manfred on 29/11/2016.
//  Copyright © 2016 Manfred Kern. All rights reserved.
//

#import "Browsers.h"

@implementation Browsers

#pragma mark - Constants

+ (TSupportedBrowser) kGoogle {
    return @"Google Chrome";
}
+ (TSupportedBrowser) kSafari {
    return @"Safari";
}
+ (TSupportedBrowser) kFirefox {
    return @"Firefox";
}

static BOOL _deepSearchAppDirs = NO;
+ (BOOL)deepSearchAppDirs {
    return _deepSearchAppDirs;
}
+ (void)setDeepSearchAppDirs:(BOOL)newDeepSearchAppDirs {
    _deepSearchAppDirs = newDeepSearchAppDirs;
}

/**
 supported browsers
 Since there are no constant arrays of NSStrings in Objective-C one needs to create a readonly property
 and write a getter for instantiation with supported browsers
 */
@synthesize supportedBrowsers = _supportedBrowsers;
- (TSupportedBrowsers) supportedBrowsers {
    if (!_supportedBrowsers)
        _supportedBrowsers = @[@"Safari", @"Google Chrome", @"Firefox"];
    return _supportedBrowsers;
}

#pragma mark - Initialization

/**
 sharedInstance: singleton for this class
 */
+ (Browsers *)sharedInstance {
    static Browsers *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Browsers alloc] init];
    });
    
    return sharedInstance;
}

/**
 init: initializes instance and search for supported installed browsers in application directory
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // determine installed browsers
        
        NSMutableArray<NSString *> *browsers = [[NSMutableArray alloc] init];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // get all entries in the application directory and subdirectories
        NSArray<NSURL *> *dirContent = [fm URLsForDirectory:NSApplicationDirectory
                                                  inDomains:NSLocalDomainMask | NSUserDomainMask];
        
        for (NSURL *url in dirContent) {
            // Check every application directory (and subdirectories)
            id val;
            NSDirectoryEnumerationOptions options =
                Browsers.deepSearchAppDirs ?    NSDirectoryEnumerationSkipsPackageDescendants |
                                                NSDirectoryEnumerationSkipsHiddenFiles :
                                                NSDirectoryEnumerationSkipsPackageDescendants |
                                                NSDirectoryEnumerationSkipsHiddenFiles |
                                                NSDirectoryEnumerationSkipsSubdirectoryDescendants;
            
    
            NSDirectoryEnumerator<NSURL *> *dirEnum = [fm enumeratorAtURL:url
                                               includingPropertiesForKeys:@[NSURLIsApplicationKey]
                                                                  options:options
                                                             errorHandler:nil];
            for (NSURL *p in dirEnum) {
                // check for supported browsers
                if ([p getResourceValue:&val forKey:NSURLIsApplicationKey error:nil]) {
                    if ([val isKindOfClass:[NSNumber class]] &&
                        [(NSNumber *)val boolValue]) {
                        NSUInteger index = [self.supportedBrowsers indexOfObject:[[p lastPathComponent]stringByDeletingPathExtension]];
                        if (index != NSNotFound)
                            [browsers addObject:_supportedBrowsers[index]];
                    }
                }
            }
        }
        _availableBrowsers = browsers;
    }
    return self;
}


@end
