
INTRODUCTION

The point of KFAppleScriptHandlerAdditions is to make it easy to call subroutines (with arguments) 
of compiled AppleScript scripts.  With these additions, applescripts can become easily accessed
helper objects within a mostly cocoa app.  Extra script compilation is also avoided.

Certain simple argument types and returns are translated between Cocoa and AppleScript.  
Here's an (artificial) example:
 
    NSArray *numberObjects;
    numberObjects = [iTunesControllerScpt executeHandler:@"num_albums_by_artists"
                                          withParameters:@"Artist1", @"Artist2", nil];
                                  
The above would execute an applescript handler that looks like this:

    on num_albums_by_artists(artist1, artist2)
         ...
         return {num1, num2}
    end num_albums_by_artists

REQUIREMENTS

KFAppleScriptHandlerAdditions requires Mac OS X 10.2 or later on both the developer's and 
end user's machine.

To use this code in your app, you need to add the four files in the KFAppleScriptHandlerAddtions
group to your project.  Of course, you also need to know how to use the code.

FIGURING OUT USAGE

If your needs are simple, you can look at KFAppleScriptHandlerAdditionsCore.h and be done with it.
Fairly self-explanatory.

If you want/need to know how ObjC/AS translation works and how to extend it, take a look at 
KFASHandlerAdditions-TypeTranslation.h.  In general, I've tried to follow the information presented
at <http://developer.apple.com/documentation/ReleaseNotes/Cocoa/CocoaScripting.html> 
(search the page for "Better Conversion of Returned NSNumbers" - the relevant info starts there) and
<http://developer.apple.com/documentation/AppleScript/Reference/StudioReference/sr3_app_suite/chapter_3_section_20.html>
(search for "Cocoa types and their AppleScript equivalents").

NOTES/BUGS/LIMITATIONS:

1) Along that line, you won't be able to build the test target unless you have OCUnit installed.

2) I previously noted that a handler called with -[NSAppleScript executeHandler:error:withParameters:] and friends
does not have access to any scripting additions.  This is _false_.  I was fooled by scripting errors.  The errors
that bit me stem from the next point.

3) An NSString is translated to the AppleScript unicode text type.  While that's probably the best thing
to do, some AppleScript commands expect the normal text type.  For example, calling this handler

    --doomed to failure
    on say_me(str)
        say str
    end say_me

with the line

    [script executeHandler:@"say_me" withParameter:@"test"]

will fail.  You can fix it by changing the handler to

    --destined for greatness
    on say_me(str)
        say (str as text)
    end say_me

Alternatively, you can fix it in objective-c by creating a descriptor of the normal text type yourself.

testAETextDescriptor = [[NSAppleEventDescriptor descriptorWithString:@"test"] coerceToDescriptorType:'TEXT'];
[script executeHandler:@"say_me" withParameter:testAETextDescriptor];

RELATED PROJECTS:

Buzz Andersen has a similar NSAppleScript category up at <http://www.scifihifi.com/weblog/mac/Cocoa-AppleEvent-Handlers.html>.  
It lets you call handlers with positional arguments, just like KFAppleScript handler additions, but it doesn't translate 
AppleScript and ObjC types.  Use it if you don't care about translation and you want something that is very little code.

Nathan Day has a full-featured package up at <http://homepage.mac.com/nathan_day/pages/source.html#ndapplescriptobject>. 
His code allows executing handlers with positional or labeled arguments with automatic ObjC-AS translation of arguments. The 
project predates NSAppleScript, so it uses a different object as the main script class. 'Labeled arguments' means you can
perform the equivalent of the fragment

    foo for arg1 given argument:arg2 

with the ObjC code

    theSubroutine = [theNDAppleScript executeSubroutineNamed:@"foo"
                    labelsAndArguments:keyASPrepositionFor, arg1,
                    keyASPrepositionGiven, arg2, @"argument", nil];
                
With KFAppleScript you'd have to wrap the AppleScript fragment up in a handler with positional arguments.

    on foofor_givenargument_(arg1, arg2)
        foo for arg1 given argument:arg2
    end foofor_givenargument_

Use Nathan's project if you want to use labeled arguments and don't mind the extra infrastructure.

Incidentally:  I didn't know about Buzz's stuff when I wrote mine, and Nathan's at that time had no capabilities beyond
NSAppleScript.  Not particularly trying to compete. :-)

LICENSE:

KFAppleScriptHandlerAdditions is written by Ken Ferry <kenferry@mac.com> and published under
the CreativeCommons Attribution-NonCommercial license <http://creativecommons.org/licenses/by-nc/1.0/>.
If you'd like to arrange for a license other than the above, send me an email.

