//
// CoreTest.m
// KFAppleScriptHandlerAdditions
//
// Copyright (c) 2003-2004 Ken Ferry. Some rights reserved.
//

#import "CoreTest.h"
#import "KFAppleScriptHandlerAdditionsCore.h"

@implementation CoreTest

-(void)testExceptionThrowingBasic
{
    NSAppleScript *badApple = [[[NSAppleScript alloc] initWithSource:
        @"on crash_and_burn()\n\
             say 4.5\n\
        end crash_and_burn\n"] autorelease];
    
    NSAppleScript *nonCompilingApple = [[[NSAppleScript alloc] initWithSource:
        @"eat at Len's"] autorelease];
    
    NSAppleScript *misspelledHandlerApple = [[[NSAppleScript alloc] initWithSource:
        @"on why_ar_these_apples()\n\
             say 4.5\n\
         end why_ar_these_apples\n"] autorelease];
    
    
    STAssertThrowsSpecificNamed([badApple executeHandler:@"crash_and_burn"],
                                NSException,
                                @"KFASException",
                                nil);
    STAssertThrowsSpecificNamed([nonCompilingApple executeHandler:@"no_matter"],
                                NSException,
                                @"KFASException",
                                nil);
    STAssertThrowsSpecificNamed([misspelledHandlerApple executeHandler:@"why_are_these_apples"],
                                NSException,
                                @"KFASException",
                                nil);
}

-(void)testExceptionThrowingAllMethods
{
    NSAppleScript *badApple = [[[NSAppleScript alloc] initWithSource:
        @"on crash_and_burn()\n\
    say 4.5\n\
    end crash_and_burn\n\
    \n\
    on crash_with_non_incrementable(arg)\n\
    1 + arg\n\
    end crash_with_non_sayable\n\
    \n\
    on crash_with_non_addable(arg1, arg2)\n\
    arg1 + arg2\n\
    end crash_with_non_addable\n"] autorelease];
    
    // make sure it's working okay
    STAssertNoThrow([badApple executeHandler:@"crash_with_non_incrementable" withParameter:[NSNumber numberWithInt:1]], 
                    @"test script doesn't work to begin with");
    STAssertNoThrow(([badApple executeHandler:@"crash_with_non_addable" withParameters:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil]), 
                    @"test script doesn't work to begin with");
    
    // now look for the exceptions
    STAssertThrowsSpecificNamed([badApple executeHandler:@"crash_and_burn"],
                                NSException,
                                @"KFASException",
                                nil);
    STAssertThrowsSpecificNamed([badApple executeHandler:@"crash_with_non_incrementable" withParameter:@"hi"],
                                NSException,
                                @"KFASException",
                                nil);
    STAssertThrowsSpecificNamed(([badApple executeHandler:@"crash_with_non_addable" withParameters:@"hi", @"bye", nil]),
                                NSException,
                                @"KFASException",
                                nil);
    STAssertThrowsSpecificNamed(([badApple executeHandler:@"crash_with_non_addable" withParametersFromArray:[NSArray arrayWithObjects:@"hi", @"bye", nil]]),
                                NSException,
                                @"KFASException",
                                nil);    
}


-(void)testErrorDicts
{
    NSAppleScript *badApple = [[[NSAppleScript alloc] initWithSource:
        @"on crash_and_burn()\n\
    say 4.5\n\
    end crash_and_burn\n"] autorelease];
    
    NSAppleScript *nonCompilingApple = [[[NSAppleScript alloc] initWithSource:
        @"eat at Len's"] autorelease];
    
    NSAppleScript *misspelledHandlerApple = [[[NSAppleScript alloc] initWithSource:
        @"on why_ar_these_apples()\n\
    say 4.5\n\
    end why_ar_these_apples\n"] autorelease];
    
    NSDictionary *errorDict;
    
    errorDict = nil;
    [badApple executeHandler:@"crash_and_burn" error:&errorDict];
    STAssertNotNil(errorDict, nil);
    
    errorDict = nil;
    [nonCompilingApple executeHandler:@"no_matter" error:(NSDictionary **)&errorDict]; 
    STAssertNotNil(errorDict, nil);
    
    errorDict = nil;
    [misspelledHandlerApple executeHandler:@"why_are_these_apples" error:(NSDictionary **)&errorDict];
    STAssertNotNil(errorDict, nil);
}

-(void)testErrorDictsAllMethods
{
    NSAppleScript *badApple = [[[NSAppleScript alloc] initWithSource:
        @"on crash_and_burn()\n\
    say 4.5\n\
    end crash_and_burn\n\
    \n\
    on crash_with_non_incrementable(arg)\n\
    1 + arg\n\
    end crash_with_non_sayable\n\
    \n\
    on crash_with_non_addable(arg1, arg2)\n\
    arg1 + arg2\n\
    end crash_with_non_addable\n"] autorelease];
    
    // make sure it's working okay
    STAssertNoThrow([badApple executeHandler:@"crash_with_non_incrementable" withParameter:[NSNumber numberWithInt:1]], 
                    @"test script doesn't work to begin with");
    STAssertNoThrow(([badApple executeHandler:@"crash_with_non_addable" withParameters:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil]), 
                    @"test script doesn't work to begin with");
    
    // now look for the errors
    NSDictionary *errorDict;
    
    errorDict = nil;
    [badApple executeHandler:@"crash_and_burn" error:(NSDictionary **)&errorDict];
    STAssertNotNil(errorDict, nil);

    errorDict = nil;
    [badApple executeHandler:@"crash_with_non_incrementable" error:(NSDictionary **)&errorDict withParameter:@"hi"];
    STAssertNotNil(errorDict, nil);

    errorDict = nil;
    [badApple executeHandler:@"crash_with_non_addable" error:(NSDictionary **)&errorDict withParameters:@"hi", @"bye", nil];
    STAssertNotNil(errorDict, nil);
    
    errorDict = nil;
    [badApple executeHandler:@"crash_with_non_addable" error:(NSDictionary **)&errorDict withParametersFromArray:[NSArray arrayWithObjects:@"hi", @"bye", nil]];
    STAssertNotNil(errorDict, nil);
}


-(void)testExecuteMethodsStandard
{
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:
        @"on no_arg()\n\
            return \"okay\"\n\
          end no_arg\n\
          \n\
          on echo(arg)\n\
            return arg\n\
          end echo\n"] autorelease];
    
    NSAppleEventDescriptor *arg = [NSAppleEventDescriptor descriptorWithString:@"argString"];
    
    STAssertNoThrow([script executeHandler:@"no_arg"], nil);
    STAssertNoThrow([script executeHandler:@"echo" withParameter:arg], nil);
    STAssertNoThrow(([script executeHandler:@"echo" withParameters:arg, nil]), nil);
    STAssertNoThrow([script executeHandler:@"echo" withParametersFromArray:[NSArray arrayWithObject:arg]], nil);
}

- (void)testExecuteWithNil
{
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:
        @"on echo(arg)\n\
            return arg\n\
          end echo\n\
          \n\
          on no_op()\n\
          end no_op"] autorelease];
    
    STAssertThrowsSpecificNamed([script executeHandler:@"echo" withParameter:nil],
                                NSException,
                                @"NSInvalidArgumentException",
                                nil);
        
}

@end
