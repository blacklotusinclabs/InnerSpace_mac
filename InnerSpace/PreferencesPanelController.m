//
//  PreferencesPanelController.m
//  InnerSpace
//
//  Created by Gregory Casamento on 2/27/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import "PreferencesPanelController.h"
#import "PreferencesPanelCellViewController.h"
#import "ModuleView.h"
#import "InnerSpaceController.h"
#import "ScreensView.h"
#import "ScreenButton.h"
#import "ModuleTile.h"
#import "Constants.h"

@implementation PreferencesPanelController

- (id)init
{
    self = [super init];
    if(self)
    {
        // Initialize
        moduleArray = [[NSMutableArray alloc] initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startModule:)
                                                     name:ISModuleChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void) dealloc
{
    [moduleArray release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [window performClose:nil];
    
    [emptyView release];
    [super dealloc];
}

- (void) drawModuleImage:(id)sender
{
    [[NSColor blackColor] set];
    NSRectFill([module frame]);
    [module oneStep];
}

- (void) loadAllModules
{
    NSDictionary *modules = [parentController modules];
    NSArray *allKeys = [[modules allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSRect sampleRect = NSMakeRect(0, 0, 1280, 800);
    
    for(NSString *moduleName in allKeys)
    {
        // Module...
        ModuleView *view = [parentController loadModule:moduleName
                                              withFrame:sampleRect];
        ModuleTile *tile = [[ModuleTile alloc] init];
        
        // Get icon if it's present...
        if([view respondsToSelector:@selector(preview)])
        {
            tile.image = [view preview];
        }
        else
        {
            tile.image = nil;
        }
        
        if(tile.image == nil)
        {
            tile.image = [NSImage imageNamed:@"DefaultIcon"];
        }
        
        tile.moduleName = moduleName;
        [moduleArray addObject:tile];
    }
}

- (void) awakeFromNib
{
    float runSpeed = 0.5;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    runSpeed = [defaults floatForKey: @"runSpeed"];
    
    [speedSlider setFloatValue: runSpeed];
    [emptyView retain];
    
    [self loadDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:NSWindowWillCloseNotification
                                               object:window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectScreenNotification:)
                                                 name:ScreensViewSelectedScreenNotification
                                               object:nil];
    
    [self loadAllModules];

    // [controlsView setContentView:emptyView];
    [window makeKeyAndOrderFront:self];
    
}


- (void) handleNotification:(NSNotification *)notification
{
    if([[notification name] isEqualToString:NSWindowWillCloseNotification])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [parentController closePreferencePanel:self];
    }
}


- (void)selectScreenNotification:(NSNotification *)notification
{
    NSMutableDictionary *modules = [parentController modules];
    NSArray *array = [[modules allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSScreen *scr = [[notification object] screen];
    NSNumber *screenId = [[scr deviceDescription] objectForKey:@"NSScreenNumber"];
    NSString *screenKey = [NSString stringWithFormat:@"currentModule_%@",screenId];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *moduleName = [defs objectForKey:screenKey];
    NSUInteger index = [array indexOfObject:moduleName];
    NSLog(@"%@ %@ %ld",scr,moduleName,(unsigned long)index);
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [modulesTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [modulesTableView scrollRowToVisible:index];
    
    ScreenButton *button = (ScreenButton *)[notification object];
    screen = [button screen];
}

// interface callbacks
- (void) selectSaver: (id)sender
{
    if(screen == nil)
    {
        NSRunAlertPanel(@"Please select a screen", @"You must select a screen to change the background.", @"Ok", nil, nil);
        return;
    }
    
    NSInteger row = [modulesTableView selectedRow];
    NSMutableDictionary *modules = [parentController modules];
    
    if(row >= 0)
    {
        NSArray *array = [[modules allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSString *moduleName = [array objectAtIndex:row];
        NSNumber *screenId = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:moduleName forKey:@"module"];
        [dict setObject:screenId forKey:@"screen"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *defaultsString = [NSString stringWithFormat:@"currentModule_%@",screenId];
        NSString *currentModuleName = [defaults objectForKey:defaultsString];
        if([moduleName isEqualToString:currentModuleName] == NO)
        {
            [dict setObject:[NSNumber numberWithBool:NO] forKey:@"start"];
        }

        [defaults setObject: module forKey: defaultsString];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:ISSelectSaverForScreenNotification
         object:nil
         userInfo:dict];
    }
    NSLog(@"Selected %ld",row);
}

- (void)startModule: (NSNotification *)notification
{
    ModuleView *moduleView = (ModuleView *)[notification object];
    if([moduleView respondsToSelector: @selector(inspector:)])
    {
        NSView *inspectorView = nil;
        
        inspectorView = [moduleView inspector: self];
        if(inspectorView != nil)
        {
            [(NSBox *)controlsView setBorderType: NSGrooveBorder];
            [(NSBox *)controlsView setContentView: inspectorView];
            if([moduleView respondsToSelector: @selector(inspectorInstalled)])
            {
                NSLog(@"installed");
                [moduleView inspectorInstalled];
            }
        }
        else
        {
            [controlsView setContentView:emptyView];
        }
    }
    else
    {
        [controlsView setContentView:emptyView];
    }
}

- (void) loadDefaults
{
    NSNumber *screenId = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
    NSString *screenKey = [NSString stringWithFormat:@"currentModule_%@",screenId];
    NSMutableDictionary *appDefs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Polyhedra",screenKey,nil];
    // NSInteger row = 0;
    float runSpeed = 0.10;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // NSMutableDictionary *modules = [parentController modules];
    
    [defaults setFloat: runSpeed forKey: @"runSpeed"];
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults: appDefs];    

    /*
    currentModuleName = [defaults stringForKey: screenKey];
    if(currentModuleName == nil || [currentModuleName isEqualToString:@""])
    {
        currentModuleName = @"Polyhedra"; // default...
    }
    NSLog(@"current module = %@",currentModuleName);
     */
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

@implementation PreferencesPanelController (TableDelegateDataSource)
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [moduleArray count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    PreferencesPanelCellViewController *cellViewController = [[PreferencesPanelCellViewController alloc] initWithNibName:@"PreferencesPanelCellViewController"
                                                                                                                  bundle:nil];\
    ModuleTile *tile = [moduleArray objectAtIndex:row];
    NSView *view = cellViewController.view;
    
    cellViewController.image.image = tile.image;
    cellViewController.description.stringValue = tile.moduleName;
    
    return view;
}
@end

