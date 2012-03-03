//
//  ReadMeExamplesTest.m
//  KFAppleScriptHandlerAdditions
//
//  Created by Ken Ferry on 11/27/04.
//  Copyright (c) 2004 Ken Ferry. All rights reserved.
//

#import "ReadMeExamplesTest.h"
#import "KFAppleScriptHandlerAdditionsCore.h"

@implementation ReadMeExamplesTest

-(void)testUsageIntroduction
{
    NSAppleScript *iTunesControllerScpt = [[[NSAppleScript alloc] initWithSource:
        @"on num_albums_by_artists(artist1, artist2)\n\
    return {1, 2}\n\
    end num_albums_by_artists\n\
    \n"] autorelease];
    
    NSArray *numberObjects;
    numberObjects = [iTunesControllerScpt executeHandler:@"num_albums_by_artists"
                                          withParameters:@"Artist1", @"Artist2", nil];

    NSArray *expectedReturn = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil];
    STAssertEqualObjects(numberObjects, expectedReturn, nil);
}

- (void)testDifficultiesWithText
{
    NSAppleScript *script;
    
    script = [[[NSAppleScript alloc] initWithSource:
        @"on say_me(str)\n\
    say str\n\
    end say_me\n\
    \n"] autorelease];
    
    // fails
    STAssertThrows([script executeHandler:@"say_me" withParameter:@"test"], nil);
    
    // corrected from cocoa
    NSAppleEventDescriptor *testAETextDescriptor;
    testAETextDescriptor = [[NSAppleEventDescriptor descriptorWithString:@"test"] coerceToDescriptorType:'TEXT'];
    STAssertNoThrow([script executeHandler:@"say_me" withParameter:testAETextDescriptor], nil);

    // corrected from applescript
    script = [[[NSAppleScript alloc] initWithSource:
        @"on say_me(str)\n\
    say (str as text)\n\
    end say_me\n\
    \n"] autorelease];
    
    STAssertNoThrow([script executeHandler:@"say_me" withParameter:@"test"], nil);
}

@end
