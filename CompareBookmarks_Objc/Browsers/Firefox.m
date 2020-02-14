//
//  Firefox.m
//  CompareBookmarks_Objc
//
//  Created by Manfred on 19.11.18.
//  Copyright © 2018 Manfred Kern. All rights reserved.
//

#import <sqlite3.h>
#import "INIParser.h"
#import "Firefox.h"
#import "NSArray+BookmarkNode.h"

# pragma mark - Constants

// default path to Firefox bookmarks location on Mac OSX
static NSString * const kRelativePartPathToBookmarks = @"/Library/Application Support/Firefox/";
static NSString * const kBookmarksFile = @"/places.sqlite";
static NSString *const kInitFile = @"profiles.ini";


@interface Firefox()

@property (nonatomic, class) NSString *pathToTempDatabase;

@property (class) sqlite3 *sqlite3Database;

@end


@implementation Firefox


//---------------------------------------------------------------------------
# pragma mark - Accessors

// path to the Profiles directroy starting from the home directory
static NSString *_relativePathToBookmarks = nil;
+ (NSString const *)relativePathToBookmarks
{
    if (_relativePathToBookmarks != nil)
        return _relativePathToBookmarks;
    
    // Getting the bookmark file from firefox is a 2-step process:
    // 1. Get the profile.ini file
    // 2. Get the default bookmark file from the ini-file
    
    // Set the documents directory path to the documentsDirectory property.
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:kRelativePartPathToBookmarks];
    
    // Read the INI-File
    INIParser *parser = [[INIParser alloc] init];
    INIP_Error_codes err = [parser parse:[path stringByAppendingPathComponent:kInitFile]];
    if (err != INIP_ERROR_NONE) {
        NSLog(@"Cannot parse INI file at %@", [path stringByAppendingPathComponent:kInitFile]);
        return nil;
    }
    // Look for section starting with "Profile" and having a
    NSString *profilePath = nil;
    for ( NSString *section in [parser sections]) {
        if ([section hasPrefix:@"Profile"] == NO)
            continue;
        NSString *defaultValue = [parser get:@"Default" fromSection:section];
        if (!defaultValue)
            continue;
        if ([defaultValue isEqualToString:@"1"]) {
            // found profile pathname
            profilePath = [parser get:@"Path" fromSection:section];
            if (!profilePath) {
                NSLog(@"No valid value for section %@ with key %@", section, @"Path");
                return nil;
            }
            else
                break;
        }
    }
    
    if (!profilePath)
        return nil;
    _relativePathToBookmarks = [path stringByAppendingPathComponent:profilePath];
    return _relativePathToBookmarks;
    
}

// The Firefox filename of its bookmarks DB
static NSString *_bookmarksFile = nil;
+ (NSString const *)bookmarksFile {return kBookmarksFile; }

// Full path to the location, where the Firefox DB will be copied temporarily
static NSString *_pathToTempDatabase = nil;
+ (NSString *)pathToTempDatabase { return _pathToTempDatabase; }
+ (void)setPathToTempDatabase:(NSString *)pathToTempDatabase { _pathToTempDatabase = pathToTempDatabase; }

// The connection of the SQLite DB of the temporary bookmarks file
static sqlite3 *_sqlite3Database = nil;
+ (sqlite3 *)sqlite3Database { return _sqlite3Database; }
+ (void)setSqlite3Database:(sqlite3 *)sqlite3Database { _sqlite3Database = sqlite3Database;}

#pragma mark - database related operations

/**
 copyBookmarksFileTemporary: Copies Firefox Bokkmarks file to a temporary directory,
 so that it is not locked (Firefox Bookmarks is a sqlite DB
 
 @return temporary file of Firefox Bookmarks to work on it (open, query, close)
 */
+ (void)copyBookmarksFileTemporary
{
    self.pathToTempDatabase = nil;
    
    // We are doing file operations
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *fullPathName =  [self.relativePathToBookmarks stringByAppendingPathComponent:kBookmarksFile];
    
    // Check whether bookmark file exists
    if ([fm fileExistsAtPath:fullPathName] == NO) {
        NSLog(@"Bookmark file does not exist at %@", fullPathName);
        return;
    }
    
    // Copy database to temp. Directory, so that source db is not locked
    
    // First check it file already exists in the temp. directory
    NSURL *tmpDir = [fm temporaryDirectory];
    self.pathToTempDatabase = [tmpDir.path stringByAppendingPathComponent:kBookmarksFile];
    
    if ([fm fileExistsAtPath:self.pathToTempDatabase] == NO) {
        
        // The database file does not exist in the documents directory, so copy it
        if ([fm copyItemAtPath:fullPathName toPath:self.pathToTempDatabase error:&error] == NO) {
            // Check if any error occurred during copying and display it.
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            self.pathToTempDatabase = nil;
            return;
        }
    }
    
    return;
}


/**
 Opens the Firefox DB of the bookmarks.
 In order to avoid blocking the original Firefox DB, it is first copied to a temporay location.

 @return Yes: can open. NO: error
 */
+ (BOOL)openDB
{
    // Copy database to temporary location
    [self copyBookmarksFileTemporary];
    if (self.pathToTempDatabase == nil)
        return false;
    
    // Open the database.
    int openDatabaseResult = sqlite3_open([self.pathToTempDatabase UTF8String], &(_sqlite3Database));
    if (openDatabaseResult != SQLITE_OK) {
        NSLog(@"Failed to open database: %@", [[NSString alloc] initWithUTF8String:sqlite3_errmsg(self.sqlite3Database)]);
        return false;
    }
    return true;
}

/**
 Closes the Firefox DB of the bookmarks
 */
+ (void)closeDB
{
    if (self.sqlite3Database) {
        if (sqlite3_close(self.sqlite3Database) != SQLITE_OK) {
            NSLog(@"Database could not be closed");
        }
        self.sqlite3Database = nil;
    }
    // Delete temp. file
    
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // SQLite creates additional temp. files when opening its database file
    // --> Find all files in temp directory belonging to Firefox (places.sqlite*)
    NSString *path = self.pathToTempDatabase.stringByDeletingLastPathComponent;
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:path error:&error];
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@",
                           self.pathToTempDatabase.lastPathComponent];
    NSArray<NSString *> *filesToDelete = [files filteredArrayUsingPredicate:filter];
    for (NSString *file in filesToDelete) {
        [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}


/**
 query (reads) the Firefox bookmarks DB and create an array of bookmark nodes.
 A bookmark node is a tree-like structure

 @return Array of bookmark nodes or nil in case of error
 */
+ (NSMutableArray<BookmarkNode *> *)queryBookmarks
{
    // The databas should alredy be opened
    assert(self.sqlite3Database);
    
    // ---------------------------------------------------------------------
    // To be independent of the sequence of bookmarks in FF bookmarks db
    // we will have two passes:
    // 1. collect all bookmark (nodes) in a map
    // 2. Append children to bookmark nodes (to its parent)
    // ---------------------------------------------------------------------
    
    // ---------------------------------------------------------------------
    // 1. Pass: read all bookmark(nodes) from FF DB
    // ---------------------------------------------------------------------
    
    // Constants defining important records in MOZ_BOOKMARKS table
    
#define MOZ_BOOKMARKS_MENU_ID 2
#define MOZ_BOOKMARKS_TOOLBAR_ID 3
    
#define MOZ_BOOKMARKS_BOOKMARKSBAR @"toolbar"
#define MOZ_BOOKMARKS_OTHERBOOKMARKS @"menu"

#define MOZ_BOOKMARKS_TYPE_FOLDER 2
    
    // Sorting by parent & title gives an internal sorted BookmarkNodes Array
    // -> so we do not need to sort it again
    const char* sql_queryBookmarks =
        "SELECT id, type, title, fk, parent FROM moz_bookmarks ORDER BY parent, id, title";
    sqlite3_stmt *compiledQueryBookmarks;
    int res = sqlite3_prepare_v2(self.sqlite3Database, sql_queryBookmarks, -1, &compiledQueryBookmarks, nil);
    if (res != SQLITE_OK) {
        NSLog(@"Failed to query database for Bookamrks: %@", [[NSString alloc] initWithUTF8String:sqlite3_errmsg(self.sqlite3Database)]);
        return nil;
    }
    
    // Some housekeeping vars
    BookmarkNode *bookmarkNode = nil;
    NSMutableDictionary<NSNumber*, BookmarkNode *> *index2BookmarkPtr = [[NSMutableDictionary alloc] init];  // FF Bookmark node number to bookmarkNode
    NSMutableDictionary<NSNumber*, NSMutableArray*> *parent2Children = [[NSMutableDictionary alloc] init]; // an array of all children of a specific parent
    
    // For each entry in moz_bookmarks table add bookmark resp. bookmark folder
    while (sqlite3_step(compiledQueryBookmarks) == SQLITE_ROW) {
        
        // SQL statement: read moz_bookmarks table
#define MOZ_BOOKMARKS_ID        0   // Number of Id-Columns in moz_bookmarks table
#define MOZ_BOOKMARKS_TYPE      1   // Number of Type-Columns in moz_bookmarks table
#define MOZ_BOOKMARKS_TITLE     2   // Number of Title-Columns in moz_bookmarks table
#define MOZ_BOOKMARKS_FK        3   // Number of FK-Columns in moz_bookmarks table
#define MOZ_BOOKMARKS_PARENT    4   // Number of Parent Column in moz_bookmarks table

        // Grab the values of the rows
        int dbId = sqlite3_column_int(compiledQueryBookmarks, MOZ_BOOKMARKS_ID);
        int dbType = sqlite3_column_int(compiledQueryBookmarks, MOZ_BOOKMARKS_TYPE);
        NSString *dbTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledQueryBookmarks,
                                                                                       MOZ_BOOKMARKS_TITLE)];
        int dbFk = sqlite3_column_int(compiledQueryBookmarks, MOZ_BOOKMARKS_FK);
        int dbParent = sqlite3_column_int(compiledQueryBookmarks, MOZ_BOOKMARKS_PARENT);
        
        if ([dbTitle length] == 0)
            continue;
        
        if ([dbTitle compare:MOZ_BOOKMARKS_OTHERBOOKMARKS] == NSOrderedSame )
            dbTitle = MKEOtherBookmarks;
        else if ([dbTitle compare:MOZ_BOOKMARKS_BOOKMARKSBAR] == NSOrderedSame)
            dbTitle = MKEBookmarkBar;
        
        if (dbType == MOZ_BOOKMARKS_TYPE_FOLDER) {
            
            // Process bookmark folders
            bookmarkNode = [[BookmarkNode alloc] initWithName:dbTitle
                                                         type:MKEBookmarkNodeTypeFolder
                                                          url:nil
                                                       parent:nil];
        } else {
            // leaf (bookmark): get url from table "moz_places" where id = fk
            if (dbFk != 0) {
                // SQL statement: read moz_places table (fk = foreign key)
                const char* sql_queryUrl = ("SELECT url FROM moz_places WHERE id = :fk");
                sqlite3_stmt *compiledQueryUrl;
                res = sqlite3_prepare_v2(self.sqlite3Database, sql_queryUrl, -1, &compiledQueryUrl, nil);
                if (res != SQLITE_OK) {
                    NSLog(@"Failed to query database for URLs: %@", [[NSString alloc] initWithUTF8String:sqlite3_errmsg(self.sqlite3Database)]);
                } else
                    if (sqlite3_bind_int(compiledQueryUrl, sqlite3_bind_parameter_index(compiledQueryUrl, ":fk"), dbFk) != SQLITE_OK) {
                        NSLog(@"Failed to query database for URLs: %@", [[NSString alloc] initWithUTF8String:sqlite3_errmsg(self.sqlite3Database)]);
                    }
                
                // URL found --> create bookmarkNode for the bookmark
                while (sqlite3_step(compiledQueryUrl) == SQLITE_ROW) {
#define MOZ_PLACES_URL 0
                    char *dbUrl = (char *)sqlite3_column_text(compiledQueryUrl, MOZ_PLACES_URL);
                    // Create bookmark
                    bookmarkNode = [[BookmarkNode alloc] initWithName:dbTitle
                                                                 type:MKEBookmarkNodeTypeUrl
                                                                  url:[NSString stringWithUTF8String:dbUrl]
                                                               parent:nil];
                }
                
                // Release SQL query
                if (sqlite3_finalize(compiledQueryUrl) != SQLITE_OK)
                    NSLog(@"Cannot finalize complied URL query");
                
            } else {
                // Create bookmark
                bookmarkNode = [[BookmarkNode alloc] initWithName:dbTitle
                                                             type:MKEBookmarkNodeTypeUrl
                                                              url:nil
                                                           parent:nil];
            }

        }
        
        // Housekeeping
        index2BookmarkPtr[@(dbId)] = bookmarkNode;
        NSMutableArray *children = [parent2Children objectForKey:@(dbParent)];
        if (!children) {
            children = [[NSMutableArray alloc] init];
            parent2Children[@(dbParent)] = children;
        }
        [children addObject:bookmarkNode];
    }
    
    // Release SQL query
    if (sqlite3_finalize(compiledQueryBookmarks) != SQLITE_OK)
        NSLog(@"Cannot finalize compiled Bookmarks query");
    
    // ---------------------------------------------------------------------
    // 2. Pass: add children to bookmark nodes
    // ---------------------------------------------------------------------
    
    BookmarkNode *parentBookmarkNode;
    for (NSNumber *key in parent2Children) {
        parentBookmarkNode = index2BookmarkPtr[key];
        parentBookmarkNode.children = [parent2Children[key] sortBookmarkNodes];
    }

    // Return value
    NSMutableArray<BookmarkNode *> *returnBookmarkNodes = [[NSMutableArray<BookmarkNode *> alloc] initWithCapacity:2];
    [returnBookmarkNodes addObject:index2BookmarkPtr[@(MOZ_BOOKMARKS_TOOLBAR_ID)]];
    [returnBookmarkNodes addObject:index2BookmarkPtr[@(MOZ_BOOKMARKS_MENU_ID)]];

    return returnBookmarkNodes;
}


#pragma mark - Reading Bookmark File


/**
 Reads the Firefox bookmarks DB and create an array of bookmark nodes.
 A bookmark node is a tree-like structure
 
 @param url full path to Firefox bookmark's DB
 @return Array of bookmark nodes or nil in case of error
 */
+ (NSMutableArray<BookmarkNode *> *)readFile:(NSURL *)url
{
    // open DB
    if (![self openDB]) {
        NSLog(@"Cannot open Firefox bookmark file");
        return nil;
    }
    
    // query DB
    NSMutableArray<BookmarkNode *> *bookmarkNodes = [self queryBookmarks];
    
    // close DB
    [self closeDB];
    
    return bookmarkNodes;
}

@end
