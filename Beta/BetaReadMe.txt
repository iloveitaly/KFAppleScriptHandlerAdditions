The stuff here doesn't work and is completely unstructured.  It's me playing around to see what works.
This is probably too nasty to be interesting to anyone, but I'll leave it in the project.  At least the
goal is interesting.  

The goal is to do transparent bridging.  I'd like to call

[iTunesControllerScpt playPlaylistNamed:@"Library"];

and have that work.  That particular example wouldn't be hard to handle, but it'd be good to 
try to deal with named parameters and the whole works.  

I'm currently stuck on getting OSAGetHandlerNames to give correct results.  I haven't found the  
right scripting component to use as an argument to the call.  If you want to contribute to the cause, 
send me an email. <kenferry@mac.com>


(so I can remember) It's also possible to make built in cocoa scripting do translations for us by doing
some silly looking tricks - take an objC object to be translated, put it in some instance variable.  
Set up code for calling ahandler without any argument or return translation.  Call
a no-argument applescript handler that uses 'call method' to get the object from cocoa.  Return it
and you have yourself in objC an apple event descriptor representing the original object. For the other direction,
call a handler with a single parameter, the descriptor to translate.  From there use 'call method' to 
set it into an instance variable of an obj-c class.  Voila, translated.