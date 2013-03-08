//
//  PreferencesPanelController.m
//  InnerSpace
//
//  Created by Gregory Casamento on 2/27/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import "PreferencesPanelController.h"
#import "ModuleView.h"
#import "InnerSpaceController.h"

@implementation PreferencesPanelController

- (id) init
{
    if(nil != (self = [super init]))
    {
    }
    
    return self;
}

- (void) dealloc
{
    // [window performClose:nil];
    [emptyView release];
    [super dealloc];
}

- (void) awakeFromNib
{
    float runSpeed = 0.5;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    runSpeed = [defaults floatForKey: @"runSpeed"];
    
    screen = [window screen];
    
    [speedSlider setFloatValue: runSpeed];
    [emptyView retain];
    
    [self loadDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:NSWindowWillCloseNotification
                                               object:window];
    [window makeKeyAndOrderFront:self];
}

- (void) handleNotification:(NSNotification *)notification
{
    if([[notification name] isEqualToString:NSWindowWillCloseNotification])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [parentController closeAllPreferencesPanels];
    }
}

// interface callbacks
- (void) selectSaver: (id)sender
{
    id module = nil;
    NSInteger row = [moduleList selectedRowInColumn: [moduleList selectedColumn]];
    NSMutableDictionary *modules = [parentController modules];
    
    if(row >= 0)
    {
        NSDictionary *dict = [NSDictionary
                              dictionaryWithObjectsAndKeys:
                              module,@"module",screen,@"screen",nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        module = [[modules allKeys] objectAtIndex: row];
        [defaults setObject: module forKey: @"currentModule"];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ISSelectSaverForScreeNotification"
         object:nil
         userInfo:dict];
    }
}

- (void) inBackground: (id)sender
{
    isInBackground = ([inBackground state] == NSOnState);
}

- (void) locker: (id)sender
{
    isLocker = ([locker state] == NSOnState);
}

- (void) saver: (id)sender
{
    isSaver = ([saver state] == NSOnState);
}

- (void) doSaver: (id)sender
{
    [parentController startSaver];
}

- (void)startModule: (NSNotification *)notification
{
    ModuleView *moduleView = (ModuleView *)[notification object];
    if([moduleView respondsToSelector: @selector(inspector:)])
    {
        NSView *inspectorView = nil;
        
        inspectorView = [moduleView inspector: self];
        [inspectorView retain];
        // NSLog(@"inspectorView %@",inspectorView);
        [(NSBox *)controlsView setBorderType: NSGrooveBorder];
        [(NSBox *)controlsView setContentView: inspectorView];
        if([moduleView respondsToSelector: @selector(inspectorInstalled)])
        {
            NSLog(@"installed");
            [moduleView inspectorInstalled];
        }
    }
}

- (void) loadDefaults
{
    NSMutableDictionary *appDefs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Polyhedra",@"currentModule_0",nil];
    NSInteger row = 0;
    float runSpeed = 0.10;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *modules = [parentController modules];
    
    [defaults setFloat: runSpeed forKey: @"runSpeed"];
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults: appDefs];
    
    NSNumber *screenId = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
    NSString *screenKey = [NSString stringWithFormat:@"currentModule_%@",screenId];
    currentModuleName = [defaults stringForKey: screenKey];
    
    if(currentModuleName == nil || [currentModuleName isEqualToString:@""])
    {
        currentModuleName = @"Polyhedra"; // default...
    }
    
    row = [[modules allKeys] indexOfObject: currentModuleName];
    if(row < [[modules allKeys] count])
    {
        [moduleList reloadColumn: 0];
        [moduleList selectRow: row inColumn: 0];
    }
    
    NSLog(@"current module = %@",currentModuleName);
}

- (void) setParentController:(InnerSpaceController *)controller
{
    parentController = controller;
}

- (InnerSpaceController *)parentController
{
    return parentController;
}
@end

// delegate
@interface PreferencesPanelController (BrowserDelegate)
- (BOOL) browser: (NSBrowser*)sender selectRow: (int)row inColumn: (int)column;

- (void) browser: (NSBrowser *)sender createRowsForColumn: (int)column
        inMatrix: (NSMatrix *)matrix;

- (NSString*) browser: (NSBrowser*)sender titleOfColumn: (int)column;

- (void) browser: (NSBrowser *)sender
 willDisplayCell: (id)cell
           atRow: (int)row
          column: (int)column;

- (BOOL) browser: (NSBrowser *)sender isColumnValid: (int)column;
@end

@implementation PreferencesPanelController (BrowserDelegate)
- (BOOL) browser: (NSBrowser*)sender selectRow: (int)row inColumn: (int)column
{
    return YES;
}

- (void) browser: (NSBrowser *)sender createRowsForColumn: (int)column
        inMatrix: (NSMatrix *)matrix
{
    NSArray *array = [[[parentController modules] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSEnumerator     *e = [array objectEnumerator];
    NSString    *module = nil;
    NSBrowserCell *cell = nil;
    int i = 0;
    
    while((module = [e nextObject]) != nil)
    {
        [matrix insertRow: i withCells: nil];
        cell = [matrix cellAtRow: i column: 0];
        [cell setLeaf: YES];
        i++;
        [cell setStringValue: module];
    }
}

- (NSString*) browser: (NSBrowser*)sender titleOfColumn: (int)column
{
    NSLog(@"Delegate called....");
    return @"Modules";
}

- (void) browser: (NSBrowser *)sender
 willDisplayCell: (id)cell
           atRow: (int)row
          column: (int)column
{
}

- (BOOL) browser: (NSBrowser *)sender isColumnValid: (int)column
{
    return NO;
}
@end

