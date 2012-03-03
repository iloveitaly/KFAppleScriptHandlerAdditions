//
// ASObjCTranslationTest.h
// KFAppleScriptHandlerAdditions v. 2.0, 4/27, 2004
//
// Copyright (c) 2003-2004 Ken Ferry. Some rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SenTestingKit/SenTestingKit.h>


@interface ASObjCTranslationTest : SenTestCase {
    NSAppleScript *equalityTestScript;
    NSAppleScript *withinEpsilonTestScript;
    
}

// instance methods so that STMacros work
- (NSAppleEventDescriptor *)descriptorWithASSource:(NSString *)code;
- (BOOL) areEqualASObj1:(NSAppleEventDescriptor *)desc1 obj2:(NSAppleEventDescriptor *)desc2;
- (BOOL) areCloseASNum1:(NSAppleEventDescriptor *)num1 num2:(NSAppleEventDescriptor *)num2;

@end
