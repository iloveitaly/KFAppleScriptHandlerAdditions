//
// ASObjCTranslationTest.m
// KFAppleScriptHandlerAdditions v. 2.0, 4/27, 2004
//
// Copyright (c) 2003-2004 Ken Ferry. Some rights reserved.
//

#import "ASObjCTranslationTest.h"
#import "KFAppleScriptHandlerAdditionsCore.h"
#import "KFASHandlerAdditions-TypeTranslation.h"

#ifndef KFAssertEqualASObjects 
#define KFAssertEqualASObjects(a1,a2,description) STAssertTrue([self areEqualASObj1:(a1) obj2:(a2)], (description))
#endif

#ifndef KFAssertCloseASNumbers 
#define KFAssertCloseASNumbers(a1,a2,description) STAssertTrue([self areCloseASNum1:(a1) num2:(a2)], (description))
#endif

@implementation NSNumber (KFUtilities)

- (BOOL)isEqualToNumber:(NSNumber *)aNum
                withinEpsilon:(double)epsilon
{
    double thisVal, thatVal;
    
    if (![aNum isKindOfClass:[NSNumber class]])
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"first argument to isEqualToNumber:within: must be an NSNumber"];
    }
    
    thisVal = [self doubleValue];
    thatVal = [aNum doubleValue];
    
    return ((thisVal - epsilon <= thatVal) && (thatVal <= thisVal + epsilon));
}

@end

@implementation NSAppleEventDescriptor (KFUtilities)

- (NSString *)descTypeString
{
    int descType = [self descriptorType];
    return [NSString stringWithCString:(char *)&descType length:4];
}

@end

@implementation ASObjCTranslationTest

- (void)setUp
{
    [super setUp];
    equalityTestScript = [[NSAppleScript alloc] initWithSource:@"\n\
    on test(obj1, obj2)  \n\
         obj1 is equal to obj2 \n\
    end test \n\
    "];
    
    withinEpsilonTestScript = [[NSAppleScript alloc] initWithSource:@"\n\
    on test(num1, num2)  \n\
         set epsilon to 1.0E-6 \n\
         num1 - epsilon < num2 and num2 < num1 + epsilon \n\
    end test \n\
    "];
}

- (void)tearDown
{
    [equalityTestScript release];
    [withinEpsilonTestScript release];
    [super tearDown];
}

// descriptors
- (void)testDescriptors
{
    NSAppleEventDescriptor *trueDesc;
    
    trueDesc = [self descriptorWithASSource:@"true"];
    
    // ObjC -> AS
    // descriptor needs no translation in this direction
    STAssertEqualObjects(trueDesc, [trueDesc aeDescriptorValue], @"");
}

// bools
- (void)testBools
{       
    NSAppleEventDescriptor *trueDesc, *falseDesc;
    NSNumber *trueNum, *falseNum;
    
    trueDesc = [self descriptorWithASSource:@"true"];
    falseDesc = [self descriptorWithASSource:@"false"];
    
    trueNum = [NSNumber numberWithBool:YES];
    falseNum = [NSNumber numberWithBool:NO];
    
    // AS -> ObjC
    STAssertEqualObjects([NSNumber numberWithAEDesc:trueDesc], 
                         trueNum, 
                         @"");

    STAssertEqualObjects([NSNumber numberWithAEDesc:falseDesc], 
                         falseNum, 
                         @"");
    
    // ObjC -> AS
    KFAssertEqualASObjects(trueDesc,
                           [trueNum aeDescriptorValue],
                           @"");
    
    KFAssertEqualASObjects(falseDesc,
                           [falseNum aeDescriptorValue],
                           @"");

}

// strings
- (void)testStandardStringCases
{
    NSAppleEventDescriptor *radishDesc;

    radishDesc = [self descriptorWithASSource:@"\"radish\""];
    
    // AS -> ObjC
    STAssertEqualObjects([NSString stringWithAEDesc:radishDesc], 
                         @"radish", 
                         @"");
    
    // ObjC -> AS
    KFAssertEqualASObjects(radishDesc,
                           [@"radish" aeDescriptorValue],
                           @"");
}

// arrays
- (void)testArrays
{
    NSAppleEventDescriptor *vegListDesc;
    NSArray *vegArray;

    vegListDesc = [self descriptorWithASSource:@"{\"radish\", \"carrot\"}"];
    vegArray = [NSArray arrayWithObjects:@"radish", @"carrot", nil];
    
    // AS -> ObjC
    STAssertEqualObjects([NSArray arrayWithAEDesc:vegListDesc], 
                         vegArray, 
                         @"");   
    
    // ObjC -> AS
    KFAssertEqualASObjects(vegListDesc,
                           [vegArray aeDescriptorValue],
                           @"");
}

// test numbers
- (void)testStandardNumberCases
{
    NSAppleEventDescriptor *intDesc, *doubDesc;
    NSNumber *intNum, *doubNum;
    
    intDesc = [self descriptorWithASSource:@"42"];
    doubDesc = [self descriptorWithASSource:@"3.14159"];

    intNum = [NSNumber numberWithInt:42];
    doubNum = [NSNumber numberWithDouble:3.14159];
        
    // AS -> ObjC
    STAssertEqualObjects([NSNumber numberWithAEDesc:intDesc], 
                         intNum, 
                         @"");   

    STAssertTrue([[NSNumber numberWithAEDesc:doubDesc] isEqualToNumber:doubNum
                                                        withinEpsilon:0.000001], 
                 @"");   
        
    
    // ObjC -> AS
    KFAssertEqualASObjects(intDesc,
                           [intNum aeDescriptorValue],
                           @"");
    
    
    
    KFAssertCloseASNumbers(doubDesc,
                           [doubNum aeDescriptorValue],
                           @"");
    
}

- (void)testHarderNumberCases
{
    // c num types
    NSAppleEventDescriptor *charDesc, *shortDesc, *intDesc, *longDesc, *longLongDesc;
    NSNumber               *charNum,  *shortNum,  *intNum,  *longNum,  *longLongNum;
    NSAppleEventDescriptor *uCharDesc, *uShortDesc, *uIntDesc, *uLongDesc, *uLongLongDesc;
    NSNumber               *uCharNum,  *uShortNum,  *uIntNum,  *uLongNum,  *uLongLongNum;
    NSNumber               *floatNum,  *doubleNum;
    
    // AS num types
    NSAppleEventDescriptor *int16Desc, *int32Desc, *uInt32Desc, *float32Desc, *float64Desc;
    NSNumber               *int16Num,  *int32Num,  *uInt32Num,  *float32Num,  *float64Num;

    charDesc     = [self descriptorWithASSource:[NSString stringWithFormat:@"%d", CHAR_MIN]];
    shortDesc    = [self descriptorWithASSource:[NSString stringWithFormat:@"%d", SHRT_MIN]];
    intDesc      = [self descriptorWithASSource:[NSString stringWithFormat:@"%d", INT_MIN]];
    longDesc     = [self descriptorWithASSource:[NSString stringWithFormat:@"%d", LONG_MIN]];
    longLongDesc = [self descriptorWithASSource:[NSString stringWithFormat:@"%d", LONG_MAX]];

    charNum     = [NSNumber numberWithChar:CHAR_MIN];
    shortNum    = [NSNumber numberWithShort:SHRT_MIN];
    intNum      = [NSNumber numberWithInt:INT_MIN];
    longNum     = [NSNumber numberWithLong:LONG_MIN];
    longLongNum = [NSNumber numberWithLongLong:LONG_MAX];
    
    uCharDesc     = [self descriptorWithASSource:[NSString stringWithFormat:@"%u", UCHAR_MAX/2]];
    uShortDesc    = [self descriptorWithASSource:[NSString stringWithFormat:@"%u", USHRT_MAX/2]];
    uIntDesc      = [self descriptorWithASSource:[NSString stringWithFormat:@"%u", UINT_MAX/2]];
    uLongDesc     = [self descriptorWithASSource:[NSString stringWithFormat:@"%u", ULONG_MAX/2]];
    uLongLongDesc = [self descriptorWithASSource:[NSString stringWithFormat:@"%u", ULONG_MAX/2]];
    
    uCharNum     = [NSNumber numberWithUnsignedChar:UCHAR_MAX/2];
    uShortNum    = [NSNumber numberWithUnsignedShort:USHRT_MAX/2];
    uIntNum      = [NSNumber numberWithUnsignedInt:UINT_MAX/2];
    uLongNum     = [NSNumber numberWithUnsignedLong:ULONG_MAX/2];
    uLongLongNum = [NSNumber numberWithUnsignedLong:ULONG_MAX/2];
    
    floatNum  = [NSNumber numberWithFloat:FLT_MAX];
    doubleNum = [NSNumber numberWithFloat:DBL_MAX];
    
    int16Desc   = [NSAppleEventDescriptor descriptorWithInt16:(SInt16)-32767];
    int32Desc   = [NSAppleEventDescriptor descriptorWithInt32:(SInt32)-2147483647];
    uInt32Desc  = [NSAppleEventDescriptor descriptorWithUnsignedInt32:(UInt32)12345];
    float32Desc = [NSAppleEventDescriptor descriptorWithFloat32:(Float32)2.71828];
    float64Desc = [NSAppleEventDescriptor descriptorWithFloat32:(Float64)-2.71828];
    
    int16Num   = [NSNumber numberWithInt:(SInt16)-32767];
    int32Num   = [NSNumber numberWithInt:(SInt32)-2147483647];
    uInt32Num  = [NSNumber numberWithUnsignedInt:(UInt32)12345];
    float32Num = [NSNumber numberWithFloat:(Float32)2.71828];
    float64Num = [NSNumber numberWithDouble:(Float64)-2.71828];
    
    // AS -> ObjC
    STAssertEqualObjects([NSNumber numberWithAEDesc:charDesc], charNum, @"");   
    STAssertEqualObjects([NSNumber numberWithAEDesc:shortDesc], shortNum, @"");   
    STAssertEqualObjects([NSNumber numberWithAEDesc:intDesc], intNum, @"");   
    STAssertEqualObjects([NSNumber numberWithAEDesc:longDesc], longNum, @"");   
    STAssertEqualObjects([NSNumber numberWithAEDesc:longLongDesc], longLongNum, @"");   
    
    STAssertEquals([[NSNumber numberWithAEDesc:uCharDesc] unsignedCharValue], [uCharNum unsignedCharValue], @"");   
    STAssertEquals([[NSNumber numberWithAEDesc:uShortDesc] unsignedShortValue], [uShortNum unsignedShortValue], @"");  
    // below the AS object is a huge doub which can lead to hefty roundoff error.  This implements a workaround - the check still
    // verifies that the values are close.  It's complicated because NSNumbers can't remember if they're supposed to be
    // unsigned.
    STAssertTrue([[NSNumber numberWithAEDesc:uIntDesc] isEqualToNumber:[NSNumber numberWithDouble:[uIntNum unsignedIntValue]]
                                                         withinEpsilon:1], @"");
    STAssertTrue([[NSNumber numberWithAEDesc:uLongDesc] isEqualToNumber:[NSNumber numberWithDouble:[uLongNum unsignedLongValue]]
                                                         withinEpsilon:1], @"");
    STAssertTrue([[NSNumber numberWithAEDesc:uLongLongDesc] isEqualToNumber:[NSNumber numberWithDouble:[uLongLongNum unsignedLongLongValue]]
                                                              withinEpsilon:1], @"");

    
    STAssertEqualObjects([NSNumber numberWithAEDesc:int16Desc], int16Num, @"");   
    STAssertEqualObjects([NSNumber numberWithAEDesc:int32Desc], int32Num, @"");   
    STAssertEqualObjects([NSNumber numberWithAEDesc:uInt32Desc], uInt32Num, @"");
    STAssertTrue([[NSNumber numberWithAEDesc:float32Desc] isEqualToNumber:float32Num withinEpsilon:0.000001], @"");   
    STAssertTrue([[NSNumber numberWithAEDesc:float64Desc] isEqualToNumber:float64Num withinEpsilon:0.000001], @"");

    // ObjC -> AS
    KFAssertEqualASObjects(charDesc, [charNum aeDescriptorValue], @"");
    KFAssertEqualASObjects(shortDesc, [shortNum aeDescriptorValue], @"");
    KFAssertEqualASObjects(intDesc, [intNum aeDescriptorValue], @"");
    KFAssertEqualASObjects(longDesc, [longNum aeDescriptorValue], @"");
    // an ObjC long long will go to a double in AS
    KFAssertEqualASObjects(longLongDesc, [longLongNum aeDescriptorValue], @"");
    
    KFAssertEqualASObjects(uCharDesc, [uCharNum aeDescriptorValue], @"");
    KFAssertEqualASObjects(uShortDesc, [uShortNum aeDescriptorValue], @"");
    KFAssertEqualASObjects(uIntDesc, [uIntNum aeDescriptorValue], @"");
    KFAssertEqualASObjects(uLongDesc, [uLongNum aeDescriptorValue], @"");
    KFAssertEqualASObjects(uLongLongDesc, [uLongLongNum aeDescriptorValue], @"");
    
    KFAssertEqualASObjects(int16Desc, [int16Num aeDescriptorValue], @"");
    KFAssertEqualASObjects(int32Desc, [int32Num aeDescriptorValue], @"");
    KFAssertEqualASObjects(uInt32Desc, [uInt32Num aeDescriptorValue], @"");
    KFAssertCloseASNumbers(float32Desc, [float32Num aeDescriptorValue], @"");
    KFAssertCloseASNumbers(float64Desc, [float64Num aeDescriptorValue], @""); 

    // ObjC -> AS -> ObjC
    
    // since getting floats into applescript is nontrivial (without using the stuff we're
    // testing), we'll just check the roundtrip values
    STAssertTrue([[NSNumber numberWithAEDesc:[floatNum aeDescriptorValue]] isEqualToNumber:floatNum withinEpsilon:0.000001], @"");
    STAssertTrue([[NSNumber numberWithAEDesc:[doubleNum aeDescriptorValue]] isEqualToNumber:doubleNum withinEpsilon:0.000001], @""); 
    
    // same deal with really big magnitude ints
    NSNumber *bigLongLongNum, *bigUnsignedLongLongNum;
    bigLongLongNum         = [NSNumber numberWithLongLong:LONG_LONG_MAX];
    bigUnsignedLongLongNum = [NSNumber numberWithUnsignedLongLong:ULONG_LONG_MAX/2];
    STAssertEqualObjects([NSNumber numberWithAEDesc:[bigLongLongNum aeDescriptorValue]], bigLongLongNum, @"");
    STAssertEqualObjects([NSNumber numberWithAEDesc:[bigUnsignedLongLongNum aeDescriptorValue]], bigUnsignedLongLongNum, @"");

}

- (void)numberTestsThatWillFail
{
    // unsigned problems, roundoff problems..
}

// dates
- (void)testDates
{
    NSAppleEventDescriptor *bdayDesc;
    NSDate *bdayDate;
    
    bdayDesc = [self descriptorWithASSource:@"date \"May 7, 1980 10:00 AM\""];
    bdayDate = [NSDate dateWithNaturalLanguageString:@"May 7, 1980 10:00 AM"];
    
    // AS -> ObjC
    STAssertEqualObjects([NSDate dateWithAEDesc:bdayDesc], 
                         bdayDate, 
                         @"");   
    
    // ObjC -> AS
    KFAssertEqualASObjects(bdayDesc,
                           [bdayDate aeDescriptorValue],
                           @"");
    
}

// points
- (void)testPoints
{
    NSPoint piByEPoint;
    NSAppleEventDescriptor *piByEDesc;
    NSArray *expectedResult, *actualResult;
    
    piByEPoint = NSMakePoint(3.14159, 2.71828);
    expectedResult = [NSArray arrayWithObjects:
        [NSNumber numberWithFloat:3.14159],
        [NSNumber numberWithFloat:2.71828],
        nil];
    
    piByEDesc    = [[NSValue valueWithPoint:piByEPoint] aeDescriptorValue];
    actualResult = [piByEDesc objCObjectValue];
    
    STAssertTrue([actualResult isKindOfClass:[NSArray class]], @"");
    STAssertEquals((int)[actualResult count], (int)2, @"");
    STAssertTrue([[actualResult objectAtIndex:0] isEqualToNumber:[expectedResult objectAtIndex:0]
                                                   withinEpsilon:0.000001], @"");
    STAssertTrue([[actualResult objectAtIndex:1] isEqualToNumber:[expectedResult objectAtIndex:1]
                                                   withinEpsilon:0.000001], @"");    
}

// ranges
- (void)testRanges
{
    NSAppleEventDescriptor *tenPaceFromFourDesc;
    NSRange tenPaceFromFourRange;
    
    tenPaceFromFourDesc  = [self descriptorWithASSource:@"{4, 14}"];
    tenPaceFromFourRange = NSMakeRange(4, 10);
    
    // ObjC -> AS
    KFAssertEqualASObjects(tenPaceFromFourDesc,
                           [[NSValue valueWithRange:tenPaceFromFourRange] aeDescriptorValue],
                           @"");
    
}

// rects
- (void)testRects
{
    NSRect negWidthRect;
    NSAppleEventDescriptor *negWidthDesc;
    NSArray *expectedResult, *actualResult;
    
    negWidthRect   = NSMakeRect(9.5, 1.2, -1.5, 3);
    expectedResult = [NSArray arrayWithObjects:
        [NSNumber numberWithFloat:9.5],
        [NSNumber numberWithFloat:1.2],
        [NSNumber numberWithFloat:8.0],
        [NSNumber numberWithFloat:4.2],
        nil];
        
    // ObjC -> AS
    
    // it's kind of hard to test that we got what we expected in applescript, we'd have to write another script
    // (because of the floats). Instead we'll bring it back to objc and check the roundtrip result.
    negWidthDesc = [[NSValue valueWithRect:negWidthRect] aeDescriptorValue];
    actualResult = [negWidthDesc objCObjectValue];
    
    STAssertTrue([actualResult isKindOfClass:[NSArray class]], @"");
    STAssertEquals((int)[actualResult count], (int)4, @"");
    STAssertTrue([[actualResult objectAtIndex:0] isEqualToNumber:[expectedResult objectAtIndex:0]
                                                   withinEpsilon:0.000001], @"");
    STAssertTrue([[actualResult objectAtIndex:1] isEqualToNumber:[expectedResult objectAtIndex:1]
                                                   withinEpsilon:0.000001], @"");
    STAssertTrue([[actualResult objectAtIndex:2] isEqualToNumber:[expectedResult objectAtIndex:2]
                                                   withinEpsilon:0.000001], @"");
    STAssertTrue([[actualResult objectAtIndex:3] isEqualToNumber:[expectedResult objectAtIndex:3]
                                                   withinEpsilon:0.000001], @"");

}

// sizes
- (void)testSizes
{
    NSSize piByESize;
    NSAppleEventDescriptor *piByEDesc;
    NSArray *expectedResult, *actualResult;
    
    piByESize = NSMakeSize(3.14159, 2.71828);
    expectedResult = [NSArray arrayWithObjects:
        [NSNumber numberWithFloat:3.14159],
        [NSNumber numberWithFloat:2.71828],
        nil];
    
    piByEDesc    = [[NSValue valueWithSize:piByESize] aeDescriptorValue];
    actualResult = [piByEDesc objCObjectValue];
    
    STAssertTrue([actualResult isKindOfClass:[NSArray class]], @"");
    STAssertEquals((int)[actualResult count], (int)2, @"");
    STAssertTrue([[actualResult objectAtIndex:0] isEqualToNumber:[expectedResult objectAtIndex:0]
                                                   withinEpsilon:0.000001], @"");
    STAssertTrue([[actualResult objectAtIndex:1] isEqualToNumber:[expectedResult objectAtIndex:1]
                                                   withinEpsilon:0.000001], @"");    
    
}

// dictionaries
- (void)testRecordsKeyedWithStrings
{
    NSAppleEventDescriptor *vegRecDesc;
    NSDictionary *vegDictionary;
    
    vegRecDesc = [self descriptorWithASSource:@"{radish:\"carrot\", peas:\"squash\"}"];
    vegDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"carrot", @"radish", @"squash", @"peas", nil];
    
    
    // AS -> ObjC
    STAssertEqualObjects([NSDictionary dictionaryWithAEDesc:vegRecDesc], 
                         vegDictionary, 
                         @"");   
    
    // ObjC -> AS
    KFAssertEqualASObjects(vegRecDesc,
                           [vegDictionary aeDescriptorValue],
                           @"");
}

- (void)testRecordsKeyedWithSpecialKeys
{
    NSAppleEventDescriptor *textAttrDesc;
    NSDictionary *textAttrDict;
    
    // dictionaries
    textAttrDesc = [self descriptorWithASSource:@"{size:\"large\"}"];
    textAttrDict = [NSDictionary dictionaryWithObjectsAndKeys:@"large", [NSNumber numberWithInt:'ptsz'], nil];
    
    
    // AS -> ObjC
    STAssertEqualObjects([NSDictionary dictionaryWithAEDesc:textAttrDesc], 
                         textAttrDict, 
                         @"");   
    
    // ObjC -> AS
    KFAssertEqualASObjects(textAttrDesc,
                           [textAttrDict aeDescriptorValue],
                           @"");
}

- (void)testNull
{
    NSAppleEventDescriptor *nullDesc;
    NSNull *nullObj;
    
    // null
    nullDesc = [self descriptorWithASSource:@""];
    nullObj = [NSNull null];
    
    
    // AS -> ObjC
    STAssertEqualObjects([NSNull nullWithAEDesc:nullDesc], 
                         nullObj, 
                         @"");   
    
    // ObjC -> AS
    KFAssertEqualASObjects(nullDesc,
                           [nullObj aeDescriptorValue],
                           @"");
    
}



- (NSAppleEventDescriptor *)descriptorWithASSource:(NSString *)code
{
    NSAppleScript *script;
    NSAppleEventDescriptor *desc;
    NSDictionary *errorDict = nil;
    
    script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"%@", code]] autorelease];
    desc = [script executeAndReturnError:&errorDict];
    
    if (errorDict != nil)
    {
        STFail(@"Badly crafted source in descriptorWithASSource:.\n%@: %@",
            [errorDict objectForKey:NSAppleScriptErrorBriefMessage], 
            [errorDict objectForKey:NSAppleScriptErrorMessage]);
    }
    
    return desc;
}

- (BOOL) areEqualASObj1:(NSAppleEventDescriptor *)desc1 obj2:(NSAppleEventDescriptor *)desc2
{
    NSNumber *result;
    
    // if the execute handler method is not working at some point, can try coercing descriptors and
    // using -[NSAppleEventDescriptor isEqual:]
    result = [equalityTestScript executeHandler:@"test"
                                 withParameters:desc1, desc2, nil];
    
    
    return [result boolValue];    
}

- (BOOL) areCloseASNum1:(NSAppleEventDescriptor *)num1 num2:(NSAppleEventDescriptor *)num2
{
    NSNumber *result;
    
    result = [withinEpsilonTestScript executeHandler:@"test"
                                      withParameters:num1, num2, nil];
    
    
    return [result boolValue];    
}

@end

