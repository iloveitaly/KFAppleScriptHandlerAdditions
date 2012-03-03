//
// MyWindowController.m
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

#import "MyWindowController.h"
#import "KFAppleScriptHandlerAdditionsCore.h"

@implementation MyWindowController

- init
{
    if ((self = [super init]) != nil)
    {
        // load our compiled script
        NSDictionary *error = nil;
        
        NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"iTunesController" 
                                                               ofType:@"scpt" 
                                                          inDirectory:nil];
        iTunesControllerScpt =
            [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:scriptPath]
                                                        error:&error];
        
        if (error != nil) { [NSException raise:NSGenericException format:@"There was a problem initializing the applescript."]; }
    }
    return self;
}

- (void)dealloc
{
    [iTunesControllerScpt release];
    [self setCachedPlaylistNames:nil];
    [super dealloc];
}

- (void)awakeFromNib
{
    [self refreshPlaylists:self];
    [playlistsTableView setTarget:self];
    [playlistsTableView setDoubleAction:@selector(playSelected:)];
}

- (IBAction)playSelected:(id)sender
{
    int selectedRow;
    NSString *playlistName;
    
    selectedRow = [playlistsTableView selectedRow];
    if (selectedRow != -1)
    {
        playlistName = [cachedPlaylistNames objectAtIndex:selectedRow];
        [iTunesControllerScpt executeHandler:@"play_playlist_named"
                               withParameter:playlistName];
    }
}

- (IBAction)refreshPlaylists:(id)sender
{
    NSArray *playlistNames;
    NSDictionary *error;
    error = nil;
    playlistNames = [iTunesControllerScpt executeHandler:@"playlist_names"];
    
    [self setCachedPlaylistNames:playlistNames];
    [playlistsTableView reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [cachedPlaylistNames count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [cachedPlaylistNames objectAtIndex:rowIndex];
}

- (NSArray *)cachedPlaylistNames
{
    return cachedPlaylistNames;
}

- (void)setCachedPlaylistNames:(NSArray *)playlistNames
{
    [cachedPlaylistNames autorelease];
    cachedPlaylistNames = [playlistNames retain];
}

@end
