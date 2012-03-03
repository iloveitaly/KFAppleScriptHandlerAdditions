//
//  KFAppleScriptTest.m
//  KFAppleScriptHandlerAdditions
//
//  Created by Ken Ferry on Sat Jul 24 2004.
//  Copyright (c) 2004 Ken Ferry. All rights reserved.
//

#import "KFAppleScriptTest.h"
#import "KFAppleScript.h"


@implementation KFAppleScriptTest

- (void)setUp
{
    error = nil;
}

- (void)handleASError
{
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", error];
    }
}


- (void)testStringCaseConversions
{
    NSString *underscoreStyle = @"word_word_word";
    NSString *camelCaseStyle = @"wordWordWord";
    
    STAssertEqualObjects([underscoreStyle underscoresToCamelCaseString], camelCaseStyle, nil);
    STAssertEqualObjects(underscoreStyle, [camelCaseStyle camelCaseToUnderscoresString], nil);
}

- (void)testHandlerNamesUncompiled
{
    KFAppleScript *script = [[[KFAppleScript alloc] initWithSource:
        @"on whine (reason)\n\
             3\n\ 
          end whine\n"] autorelease];
    
    STAssertEqualObjects([script kfHandlerNames], [NSArray arrayWithObject:@"whine"], nil);
}

- (void)testHandlerNamesCompiled
{    
    KFAppleScript *script = [[[KFAppleScript alloc] initWithSource:
        @"on whine (reason)\n\
    say reason\n\ 
    end whine\n"] autorelease];
        
    [script compileAndReturnError:&error];
    [self handleASError];

    STAssertEqualObjects([script kfHandlerNames], [NSArray arrayWithObject:@"whine"], nil);    
}





@end
