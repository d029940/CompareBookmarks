
#import "INIParser.h"

@interface INIParser ()

@property (nonatomic) NSMutableDictionary<NSString*, NSString*> *currentSection;

@end

#pragma mark -

@implementation INIParser

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sections = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Parsing Ini-File

- (INIP_Error_codes)parse: (NSString*)filename
{
    // Check URL for existence
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filename]) {
        NSLog(@"%@ does not exist", filename);
        return INIP_ERROR_FILE_NOT_EXIST;
    }
    
    NSError *error;
    NSString *contents = [NSString stringWithContentsOfFile:filename
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    
    if (contents == nil) {
        NSLog(@"%@", error);
        return INIP_ERROR_FOPEN_FAILED;
    }
    NSArray<NSString *> *lines = [contents componentsSeparatedByString:@"\n"];
    
    INIP_Error_codes err;
    for (NSString *line in lines) {
        err = [self parseLine:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        if (err != INIP_ERROR_NONE) return err;
    }
    
    return INIP_ERROR_NONE;
}


- (INIP_Error_codes)parseLine: (NSString *) line
{
    INIP_Error_codes err;
    
    if ([line length] == 0)
        err = INIP_ERROR_NONE;
    else if ([line characterAtIndex:0]  == ';')
        err = INIP_ERROR_NONE;  // comment
    else if ([line characterAtIndex:0]  == '[')
        err = [self parseSection: line];
    else err = [self parseAssignment: line];
    
    return err;
}

/**
 <#Description#>

 @param line <#line description#>
 @return <#return value description#>
 */
- (INIP_Error_codes)parseSection: (NSString *)line
{
    // 1. Get (key) name of section
    if ([line characterAtIndex:([line length] - 1)] != ']') return INIP_ERROR_INVALID_SECTION;
    
    NSRange nr = {1, [line length] - 2};
    NSString *name = [line substringWithRange:nr];
    
    // 2. Create an empty assingment dictionary for the current section
    self.currentSection = [[NSMutableDictionary alloc] init];
    self.sections[name] = self.currentSection;
    return INIP_ERROR_NONE;
}

- (INIP_Error_codes)parseAssignment: (NSString *)line
{
    NSString *key, *value;
    
    if (self.currentSection == nil)
        return INIP_ERROR_NO_SECTION;
    
    NSRange nr = [line rangeOfCharacterFromSet:
                  [NSCharacterSet characterSetWithCharactersInString:@"=\t "]];
    if (nr.location == NSNotFound)
        return INIP_ERROR_INVALID_ASSIGNMENT;
    
    // Get keyn and value for the assignment to insert into current section
    // e.g. key=value ==> nr.location = 3, nr.length = 1
    NSRange nrk = {0, nr.location}; // exclude separation character
    key = [[line substringWithRange:nrk] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSRange nrv = {nr.location + nr.length, [line length] - nr.location - nr.length}; //jump over separation character
    value = [[line substringWithRange:nrv] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.currentSection[key] = value;
    
    return INIP_ERROR_NONE;
}

#pragma mark - Retrieving

- (NSString *)get:(NSString*)assignmentKey fromSection:(NSString*)sectionKey
{
    NSDictionary *assignment = self.sections[sectionKey];
    if (assignment == nil) return nil;
    
    return assignment[assignmentKey];
}


- (BOOL)getBool: (NSString *)assignmentKey fromSection: (NSString *)sectionKey
{
    NSDictionary *assignment = self.sections[sectionKey];
    if (assignment == nil) return NO;
    
    NSString *value = assignment[assignmentKey];
    
    if (value != nil) {
        const char * s = [value UTF8String];
        if ((*s == 'Y') || (*s == 'y') || (*s == 'T') || (*s == 't') ||
            isdigit (*s))
            return YES;
    }
    
    return NO;
}

- (NSInteger)getInt:(NSString *)assignmentKey fromSection: (NSString *)sectionKey
{
    NSDictionary *assignment = self.sections[sectionKey];
    if (assignment == nil) return NSNotFound;
    
    NSString *value = assignment[assignmentKey];
    if (value == nil) return NSNotFound;
    
    return [value intValue];
}

@end
