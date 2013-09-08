//
//  PreferencesPanelController.h
//  InnerSpace
//
//  Created by Gregory Casamento on 2/27/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InnerSpaceController;
@class ModuleView;

@interface PreferencesPanelController : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
    // interface vars.
    // IBOutlet NSTableView *moduleList;
    IBOutlet id inBackground;
    // IBOutlet id locker;
    // IBOutlet id saver;
    // IBOutlet id run;
    IBOutlet id controlsView;
    // IBOutlet id lockerPanel;
    IBOutlet id speedSlider;
    IBOutlet NSWindow *window;    
    IBOutlet id emptyView;
    IBOutlet NSTableView *modulesTableView;
    NSMutableArray *moduleArray;
    
    // booleans...
    BOOL isSaver;
    BOOL isLocker;
    BOOL isInBackground;
    
    NSScreen *screen;
    // NSString *currentModuleName;
    id module;
    
    InnerSpaceController *parentController;
}

// methods called from interface
- (IBAction) selectSaver: (id)sender;
/*
- (IBAction) inBackground: (id)sender;
- (IBAction) locker: (id)sender;
- (IBAction) saver: (id)sender;
- (IBAction) doSaver: (id)sender;
*/

// Load & Find modules...
- (void) loadDefaults;
- (void)startModuleWithModuleView: (ModuleView *)moduleView;

- (void) setParentController:(InnerSpaceController *)controller;
- (InnerSpaceController *)parentController;

@end
