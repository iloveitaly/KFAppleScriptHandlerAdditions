//
//  KFAppleScript.m
//  KFAppleScriptHandlerAdditions
//
//  Created by Ken Ferry on Wed Jul 21 2004.
//  Copyright (c) 2004 Ken Ferry. All rights reserved.
//

// useful: http://developer.apple.com/qa/qa2001/qa1111.html

#import "KFAppleScript.h"
#import "KFAppleScriptHandlerAdditionsCore.h"
#import "KFASHandlerAdditions-TypeTranslation.h"
#import <Carbon/Carbon.h>


@implementation NSString (KFUtilities)

// status: works
- (NSString *)underscoresToCamelCaseString
{
    NSMutableString *workString = [NSMutableString stringWithString:self];

    [workString replaceOccurrencesOfString:@"_"
                                withString:@" "
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, [workString length])];
    workString = [[workString capitalizedString] mutableCopy];
    [workString replaceOccurrencesOfString:@" "
                                withString:@""
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, [workString length])];
    NSString *firstLetter = [workString substringToIndex:1];
    [workString replaceCharactersInRange:NSMakeRange(0,1)
                              withString:[firstLetter lowercaseString]];
    
    return workString;
}

// status: works
- (NSString *)camelCaseToUnderscoresString
{
    NSMutableString *workString = [NSMutableString stringWithString:self];
    NSCharacterSet *uppercaseLetterCharacterSet = [NSCharacterSet uppercaseLetterCharacterSet];
    NSRange capRange, searchRange;
    
    capRange = [workString rangeOfCharacterFromSet:uppercaseLetterCharacterSet];
    while (capRange.location != NSNotFound)
    {
        [workString insertString:@"_"
                         atIndex:capRange.location];
        // new search range starts past the underscore and the found cap
        searchRange = NSMakeRange(1 + NSMaxRange(capRange), [workString length] - 1 - NSMaxRange(capRange));
        capRange = [workString rangeOfCharacterFromSet:uppercaseLetterCharacterSet
                                               options:NSLiteralSearch 
                                                 range:searchRange];
    }
    
    return [workString lowercaseString];
}

@end

@implementation KFAppleScript

- (void)dealloc
{
    [handlerNames release];
}

/*
- (void)registerHandler:(NSString *)handlerName forSelector:(SEL)aSelector
{
    [selToHandlerMap setObject:handlerName forKey:[NSValue value:&aSelector withObjCType:@encode(SEL)]];
}
*/

// status: doesn't work, current focus
- (NSArray *)kfHandlerNames
{
    if (handlerNames == nil)
    {
        NSAppleEventDescriptor *handlerNamesDesc = [NSAppleEventDescriptor listDescriptor];
        
        // useful? OpenDefaultComponent( kOSAComponentType, kAppleScriptSubtype );
        // http://developer.apple.com/documentation/Carbon/Reference/Open_Scripti_Architecture/Open_Script_Arch/ResultCodes.html
        // http://developer.apple.com/documentation/mac/IAC/IAC-422.html
        
        // lots of extra stuff for use in gdb
        AEDesc desc1, desc2;
        desc1 = desc2; 
        OSAError osaError;
        ComponentInstance defaultScriptingComponent = [KFAppleScript _defaultScriptingComponent];
        ComponentInstance appleScriptScriptingComponent;
        
        OSType asSubtype = kAppleScriptSubtype;
        
        osaError =  OSAGetScriptingComponent(defaultScriptingComponent,
                                             asSubtype,
                                             &appleScriptScriptingComponent); 
        if (osaError != noErr)
        {
            NSDictionary *error = [NSAppleScript _infoForOSAError:osaError];
            [self kfHandleASError:error];
        }
        
        // this doesn't work.  I don't know if that's the right scripting component,
        // I don't know if I maybe have to 'open' it.  Nothing I've tried works.
        osaError = OSAGetHandlerNames (appleScriptScriptingComponent,
                                       kOSAModeNull,
                                       [self _compiledScriptID],
                                       [handlerNamesDesc aeDesc]);
        if (osaError != noErr)
        {
            NSDictionary *error = [NSAppleScript _infoForOSAError:osaError];
            [self kfHandleASError:error];
        }
        
        handlerNames = [[handlerNamesDesc objCObjectValue] retain];
    }
    
    return handlerNames;
}

// status: doesn't work, not looking at it right now
- (NSString *)kfHandlerForSelector:(SEL)aSelector
{
    NSEnumerator *handlerEnumerator = [[self kfHandlerNames] objectEnumerator];
    NSString *aHandler;
    NSString *selectorString = NSStringFromSelector(aSelector);
    
    
    while (aHandler = [handlerEnumerator nextObject])
    {
        if ([selectorString hasPrefix:aHandler])
        {
            return aHandler;
        }
    }
    
    return nil;
}

// status: doesn't work, not looking at it right now.  
// nothing wrong with it though, just doesn't match up to more current stuff.
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature;
    signature = [super methodSignatureForSelector:aSelector];
    if (nil == signature && ([self kfHandlerForSelector:aSelector] != nil))
    {
        NSMutableString *typesString = [NSMutableString stringWithString:@"@@:"];
        // FIXME - stop hacking method signature
        NSScanner *selectorScanner = [NSScanner scannerWithString:NSStringFromSelector(aSelector)];
        [selectorScanner setCharactersToBeSkipped:[[NSCharacterSet characterSetWithCharactersInString:@":"] invertedSet]];
        while ([selectorScanner scanString:@":" intoString:nil])
        {
            [typesString appendString:@"@"];
        }
        
        signature = [NSMethodSignature signatureWithObjCTypes:[typesString cString]];
    }
    
    return signature;
}

// status: doesn't work, not looking at it right now.  
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *handler = [self kfHandlerForSelector:[anInvocation selector]];
    if (handler == nil)
    {
        [super forwardInvocation:anInvocation];
    }
    else
    {
        
    }        
}

/*
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *handler = [self kfHandlerForSelector:[anInvocation selector]];
    if (handler == nil)
    {
        [super forwardInvocation:anInvocation];
    }
    else
    {
        NSMutableArray *parameterArray;
        int numArgs, curArgIndex;
        id argument;
        
        parameterArray = [NSMutableArray array];
        numArgs = [[anInvocation methodSignature] numberOfArguments];
        
        for (curArgIndex = 2; curArgIndex < numArgs; curArgIndex++)
        {
            [anInvocation getArgument:&argument atIndex:curArgIndex];
            [parameterArray addObject:argument];
        }
        
        NSDictionary *error = nil;
        id result;
        result = [self executeHandler:handler
                                error:&error 
              withParametersFromArray:parameterArray];
        
        if (error != nil)
        {
            [[NSException exceptionWithName:@"KFAppleScriptError" 
                                     reason:[error description]
                                   userInfo:error] raise];
        }
        
        [anInvocation setReturnValue:&result];
    }
}
*/

@end
