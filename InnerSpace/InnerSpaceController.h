/* All Rights reserved */

#import <AppKit/AppKit.h>
#import "SaverWindow.h"
#import "ModuleView.h"


@interface InnerSpaceController : NSObject
{    
    // internal vars.
    NSMapTable *screensToWindows;
    NSMapTable *timersToModules;
    NSMutableDictionary *modules;

    // dictionary & defaults...
    NSUserDefaults *defaults;
    // NSString *currentModuleName;
    NSMutableArray *controllers;

}

// internal methods
- (NSMutableDictionary *)modules;
- (void) destroySaverWindow;
- (void) createSaverWindow: (BOOL)desktop;
- (void) startTimer:(id)module;
- (void) stopTimer:(id)module;
- (void) resetTimer:(id)module;
- (void) runAnimation: (NSTimer *)atimer;

// Locate modules...
- (void) findModulesInDirectory: (NSString *) directory;
- (void) findModules;
- (id) loadModule: (NSString *)moduleName forScreen:(NSScreen *)screen;
- (void) closeAllPreferencesPanels;

// Actions...
- (IBAction) doSaverInBackground: (id)sender;
- (IBAction) startSaver; // : (id)sender;
- (IBAction) stopSaver; // : (id)sender;
- (IBAction) stopAndStartSaver; // : (id)sender;
- (IBAction) showPreferencePanels:(id)sender;
@end
