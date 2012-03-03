//
// MyWindowController.h
// KFAppleScriptHandlerAdditionsDemo v. 1.0, 9/06, 2003
//
// Copyright (c) 2003 Ken Ferry. Some rights reserved.
// http://homepage.mac.com/kenferry/software.html
//
// This work is licensed under a Creative Commons license:
// http://creativecommons.org/licenses/by-nc/1.0/
//
// Send me an email if you have any problems (after you've read what there is to read).
//
// You can reach me at kenferry at the domain mac.com.

#import <Cocoa/Cocoa.h>

@interface MyWindowController : NSWindowController
{
    IBOutlet id playlistsTableView;

    NSAppleScript *iTunesControllerScpt;
    NSArray *cachedPlaylistNames;
}

- (IBAction)playSelected:(id)sender;
- (IBAction)refreshPlaylists:(id)sender;

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

- (NSArray *)cachedPlaylistNames;
- (void)setCachedPlaylistNames:(NSArray *)playlistNames;

@end
