//
//  KFAppleScript.h
//  KFAppleScriptHandlerAdditions
//
//  Created by Ken Ferry on Wed Jul 21 2004.
//  Copyright (c) 2004 Ken Ferry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


@interface KFAppleScript : NSAppleScript {
    
    NSArray *handlerNames;

}
- (void)kfHandleASError:(NSDictionary *)error;
- (NSArray *)kfHandlerNames;
- (NSString *)kfHandlerForSelector:(SEL)aSelector;

@end

@interface NSString (KFUtilities)

- (NSString *)underscoresToCamelCaseString;
- (NSString *)camelCaseToUnderscoresString;

@end

@interface NSAppleEventDescriptor (NSTemporaryCompatibility)
- (id)_initWithDescriptorType:(unsigned long)fp8 bytes:(const void *)fp12 byteCount:(unsigned long)fp16;
- (id)_initWithoutAEDesc;
- (struct AEDesc *)_AEDesc;
- (void)_setAEDesc:(struct AEDesc *)fp8;
@end

@interface NSAppleScript (NSPrivate)
+ (struct ComponentInstanceRecord *)_defaultScriptingComponent;
+ (id)_infoForOSAError:(OSAError)error;
- (unsigned long)_compiledScriptID;
@end

@interface NSMethodSignature (NSPrivate)
+ (id)signatureWithObjCTypes:(const char *)types;
@end



