/**
 Description:
 Parses an INI-File comprised with sections "[section x]" and
 assignments "key=value" in the section
 Usage:
 1. Initiate INIParser using "init"-method
 2. Parse INI-File with "parse"-method
 3. Extract information with the "get"-method
 4. If value is known to be a Bool or an Int methods "getBool" and "getInt" will return the value respectively.
 */

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    INIP_ERROR_NONE,
    INIP_ERROR_FILE_NOT_EXIST,
    INIP_ERROR_INVALID_ASSIGNMENT,
    INIP_ERROR_FOPEN_FAILED,
    INIP_ERROR_INVALID_SECTION,
    INIP_ERROR_NO_SECTION
} INIP_Error_codes;

@interface INIParser : NSObject

@property NSMutableDictionary<NSString *, NSDictionary *> * sections;

- (instancetype)init;
- (INIP_Error_codes)parse: (NSString *)filename;
- (NSString *)get:(NSString*)assignmentKey fromSection:(NSString*)sectionKey;
- (BOOL)getBool: (NSString *)assignmentKey fromSection: (NSString *)sectionKey;
- (NSInteger)getInt:(NSString *)assignmentKey fromSection: (NSString *)sectionKey;

@end

