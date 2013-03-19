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
    NSRect sampleRect = NSMakeRect(0, 0, 128, 80);
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:[allKeys count]];
    
    for(NSString *moduleName in allKeys)
    {
        if([moduleName isEqualToString:@"Spor"])
        {
            continue;
        }
        
        // Module...
        ModuleView *view = [parentController loadModule:moduleName
                                              withFrame:sampleRect];
        for(int i = 0; i < 99; i++)
        {
            [view oneStep]; // step 99 steps into the view's life...
        }
        module = view;
        
        // Generate an image for the collection item...
        NSImageRep *r;
        NSImage *stipple;
        stipple = [[NSImage alloc] initWithSize: sampleRect.size];
        r = [[NSCustomImageRep alloc]
             initWithDrawSelector: @selector(drawModuleImage:)
             delegate: self];
        [r setSize: sampleRect.size];
        [stipple addRepresentation: r];
        [r release];

        // Create a collection item...
        ModuleTile *tile = [[ModuleTile alloc] init];
        tile.image = stipple;
        tile.moduleName = moduleName;
        [tiles addObject:tile];
    }
    
    // [collectionView setContent:contentArray];
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
    // NSRect screenFrame = [screen frame];
    // NSRect windowFrame = [window frame];
    
    // Set the frame...
    // windowFrame.origin.x = screenFrame.origin.x + 100;
    // windowFrame.origin.y = screenFrame.origin.y + 100;
    
    // Show the window...
    //[window setFrame:windowFrame
      //       display:NO];
    [controlsView setContentView:emptyView];
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
    NSScreen *scr = [[notification object] screen];
    NSLog(@"%@",scr);
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

