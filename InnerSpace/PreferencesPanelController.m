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
#import "ScreensView.h"
#import "ModuleTile.h"

@implementation PreferencesPanelController

- (id)init
{
    self = [super init];
    if(self)
    {
        // Do nothing..
    }
    return self;
}

- (void) dealloc
{
    [tiles removeObserver:self forKeyPath:@"selectionIndexes"];
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
    NSArray *allKeys = [modules allKeys];
    NSRect sampleRect = NSMakeRect(0, 0, 1280, 800);
    
    for(NSString *moduleName in allKeys)
    {
        // Module...
        ModuleView *view = [parentController loadModule:moduleName
                                              withFrame:sampleRect];
        ModuleTile *tile = [[ModuleTile alloc] init];
        
        // Get icon if it's present...
        if([view respondsToSelector:@selector(icon)])
        {
            tile.image = [view icon];
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
        [tiles addObject:tile];
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
    
    [tiles addObserver:self
            forKeyPath:@"selectionIndexes"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    [self loadAllModules];

    [controlsView setContentView:emptyView];
    [window makeKeyAndOrderFront:self];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if([keyPath isEqualTo:@"selectionIndexes"])
    {
        if([[tiles selectedObjects] count] > 0)
        {
            if ([[tiles selectedObjects] count] == 1)
            {
                ModuleTile *t = (ModuleTile *)
                [[tiles selectedObjects] objectAtIndex:0];
                NSLog(@"Only 1 selected: %@", t.moduleName);
            }
            else
            {
                // More than one selected - iterate if need be
            }
        }
    }
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
    NSScreen *scr = [[notification object] screen];
    NSNumber *screenId = [[scr deviceDescription] objectForKey:@"NSScreenNumber"];
    NSString *screenKey = [NSString stringWithFormat:@"currentModule_%@",screenId];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *moduleName = [defs objectForKey:screenKey];
    NSUInteger index = [[[parentController modules] allKeys] indexOfObject:moduleName];
    
    [tiles setSelectedObjects:[NSArray array]];
    [tiles setSelectionIndex:index];
    
    // NSLog(@"%@ %@ %ld",scr,moduleName,(unsigned long)index);
    
}

// interface callbacks
- (void) selectSaver: (id)sender
{
    /*
    NSInteger row = [moduleList selectedRow];
    NSMutableDictionary *modules = [parentController modules];
    
    if(row >= 0)
    {
        NSArray *array = [[modules allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSString *module = [array objectAtIndex:row];
        NSNumber *screenId = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:module forKey:@"module"];
        [dict setObject:screenId forKey:@"screen"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *defaultsString = [NSString stringWithFormat:@"currentModule_%@",screenId];
        [defaults setObject: module forKey: defaultsString];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ISSelectSaverForScreeNotification"
         object:nil
         userInfo:dict];
    }
     */
    NSLog(@"Selected");
}

/*
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
*/

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
    NSNumber *screenId = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
    NSString *screenKey = [NSString stringWithFormat:@"currentModule_%@",screenId];
    NSMutableDictionary *appDefs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Polyhedra",screenKey,nil];
    NSInteger row = 0;
    float runSpeed = 0.10;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *modules = [parentController modules];
    
    [defaults setFloat: runSpeed forKey: @"runSpeed"];
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults: appDefs];    

    currentModuleName = [defaults stringForKey: screenKey];
    if(currentModuleName == nil || [currentModuleName isEqualToString:@""])
    {
        currentModuleName = @"Polyhedra"; // default...
    }
    
    NSArray *array = [[modules allKeys] sortedArrayUsingSelector:@selector(compare:)];
    row = [array indexOfObject: currentModuleName];
    if(row < [[modules allKeys] count])
    {
        NSIndexSet *rowIndex = [NSIndexSet indexSetWithIndex:row];
        /*
        [moduleList reloadData];
        [moduleList selectRowIndexes:rowIndex byExtendingSelection:NO];
        [moduleList scrollRowToVisible:row]; // + 2];
         */
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

- (NSString *)moduleNameForScreen:(NSScreen *)screen
{
    
}

@end

@implementation PreferencesPanelController (TableDelegateDataSource)
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[[parentController modules] allKeys] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSArray *array = [[[parentController modules] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [array objectAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    NSUInteger clickedRow = [tableView clickedRow];
    NSLog(@"%ld",(unsigned long)clickedRow);
}
@end

