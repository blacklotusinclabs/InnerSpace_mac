/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "SaverWindow.h"
#import "ModuleView.h"

@class PreferencesPanelController;

@interface InnerSpaceController : NSObject
{    
    // internal vars.
    NSMapTable *screensToWindows;
    NSMapTable *timersToModules;
    NSMutableDictionary *modules;

    // NSString *currentModuleName;
    NSMutableArray *controllers;

}

// internal methods
- (NSMutableDictionary *)modules;
- (void) destroySaverWindowOnScreen:(NSScreen *)screen;
- (void) destroySaverWindow;
- (void) createSaverWindow: (BOOL)desktop;
- (void) createSaverWindow:(BOOL)desktop
                 forScreen:(NSScreen *)screen
           withModuleNamed:(NSString *)moduleName;
- (void) startTimer:(id)module;
- (void) stopTimer:(id)module;
- (void) resetTimer:(id)module;
- (void) runAnimation: (NSTimer *)atimer;

// Locate modules...
- (void) findModulesInDirectory: (NSString *) directory;
- (void) findModules;
- (id) loadModule: (NSString *)moduleName forScreen:(NSScreen *)screen;
- (void) closePreferencePanel:(PreferencesPanelController *)controller;

// Actions...
- (IBAction) doSaverInBackground: (id)sender;
- (IBAction) startSaver; // : (id)sender;
- (IBAction) stopSaver; // : (id)sender;
- (IBAction) stopAndStartSaver; // : (id)sender;
- (IBAction) showPreferencePanels:(id)sender;
@end
