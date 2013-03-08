/* All Rights reserved */

#import <AppKit/AppKit.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>
#import "InnerSpaceController.h"
#import "ModuleView.h"
#import "PreferencesPanelController.h"

#define TIME 0.10

#ifndef GNUSTEP
void DisplayReconfigurationCallBack (CGDirectDisplayID display,
                                     CGDisplayChangeSummaryFlags flags,
                                     void *userInfo);

void DisplayReconfigurationCallBack (CGDirectDisplayID display,
                                     CGDisplayChangeSummaryFlags flags,
                                     void *userInfo)
{
    InnerSpaceController *controller = (InnerSpaceController *)userInfo;
    [controller destroySaverWindow];
    [controller createSaverWindow:YES];
}
#endif

@implementation InnerSpaceController

- (id)init
{
    if(nil != ([super init]))
    {
        screensToWindows =
            NSCreateMapTable(NSObjectMapKeyCallBacks,
                             NSNonRetainedObjectMapValueCallBacks, 10);
        timersToModules =
            NSCreateMapTable(NSObjectMapKeyCallBacks,
                             NSNonRetainedObjectMapValueCallBacks, 10);
        modules = [[NSMutableDictionary alloc] initWithCapacity:10];
        controllers = [[NSMutableArray alloc] initWithCapacity:10];
        
        // Add observer...
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:@"ISSelectSaverForScreeNotification"
                                                   object:nil];
        
        // Find all modules and refresh every five minutes...
        [self findModules];
        [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)300
                                         target:self
                                       selector:@selector(findModules:)
                                       userInfo:nil
                                        repeats:YES];
        
        // [emptyView retain]; // hold on to this.
#ifndef GNUSTEP
        CGDisplayRegisterReconfigurationCallback (DisplayReconfigurationCallBack, self);
#endif
    }
    return self;
}

- (void) handleNotification: (NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    NSScreen *screen = [dict objectForKey:@"screen"];
    NSString *moduleName = [dict objectForKey:@"module"];
    [self loadModule:moduleName forScreen:screen];    
}

- (void) resetTimer:(id)module
{
    [self stopTimer:module];
    [self startTimer:module];
}

- (void) setSpeed: (id)sender
{
    id module = nil; // TODO: Fix this...
    [self resetTimer:module];
}

- (void) doSaverInBackground: (id)sender
{
    NSLog(@"Called");
    [self createSaverWindow: YES];
}

- (void) awakeFromNib
{
}

- (void) dealloc
{
    NSFreeMapTable(screensToWindows);
    NSFreeMapTable(timersToModules);
    [modules release];
    [super dealloc];
}

- (void) applicationDidFinishLaunching: (NSNotification *)notification
{
    // [self loadModule: currentModuleName];
    [self doSaverInBackground:self];
}

- (void) createSaverWindow: (BOOL)desktop
{
    NSArray *screens = [NSScreen screens];
    NSEnumerator *en = [screens objectEnumerator];
    NSScreen *screen = nil;
    
    while(nil != (screen = [en nextObject]))
    {
        SaverWindow *saverWindow = nil;
        NSRect frame = [screen frame];
        int store = NSBackingStoreRetained;
                
        // return if nil...
        NSNumber *screenId = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
        NSString *screenKey = [NSString stringWithFormat:@"currentModule_%@",screenId];
        NSString *currentModuleName = [defaults stringForKey: screenKey];
        
        if(currentModuleName == nil || [currentModuleName isEqualToString:@""])
        {
            currentModuleName = @"Polyhedra"; // default...
        }
        id currentModule = [self loadModule:currentModuleName
                                  forScreen:screen];
        if(nil == currentModule)
        {
            return;
        }
        
        // determine backing type...
        NS_DURING
        {
            if([currentModule respondsToSelector: @selector(useBufferedWindow)])
            {
                if([currentModule useBufferedWindow])
                {
                    store = NSBackingStoreBuffered;
                }
            }
        }
        NS_HANDLER
        {
            NSLog(@"EXCEPTION: %@",localException);
            store = NSBackingStoreBuffered;
        }
        NS_ENDHANDLER;
        
        // create the window...
        saverWindow = [[SaverWindow alloc] initWithContentRect: frame
                                                     styleMask: NSBorderlessWindowMask
                                                       backing: store
                                                         defer: NO];
        
        // Make sure we stay on all desktops...
        [saverWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
        
        // set some attributes...
        [saverWindow setAction: @selector(stopAndStartSaver) forTarget: self];
        [saverWindow setAutodisplay: YES];
        [saverWindow makeFirstResponder: saverWindow];
        [saverWindow setExcludedFromWindowsMenu: YES];
        [saverWindow setBackgroundColor: [NSColor blackColor]];
        [saverWindow setOneShot:YES];
        
        // set up the backing store...
        if(store == NSBackingStoreBuffered)
        {
            [saverWindow useOptimizedDrawing: YES];
            [saverWindow setDynamicDepthLimit: YES];
        }
        
        // run the saver in on the desktop...
        if(desktop)
        {
            [saverWindow setLevel: NSDesktopWindowLevel];
            [saverWindow setCanHide: NO];
        }
        else
        {
            [saverWindow setLevel: NSScreenSaverWindowLevel];
            [saverWindow setCanHide: YES];
        }
        
        // load the view from the currently active module, if
        // there is one...
        if(currentModule)
        {
            [saverWindow setContentView: currentModule];
            NS_DURING
            {
                if([currentModule respondsToSelector: @selector(willEnterScreenSaverMode)])
                {
                    [currentModule willEnterScreenSaverMode];
                }
            }
            NS_HANDLER
            {
                NSLog(@"EXCEPTION while creating saver window %@",localException);
            }
            NS_ENDHANDLER
        }
        
        NSMapInsert(screensToWindows, screen, saverWindow);

        [self startTimer:currentModule];
        [saverWindow makeKeyWindow];
        [saverWindow orderBack:self];
    }
}

- (void) destroySaverWindow
{
    NSArray *keyArray = [NSAllMapTableKeys(screensToWindows) copy];
    NSEnumerator *en = [keyArray objectEnumerator];
    NSDictionary *key = nil;
    
    while(nil != (key = [en nextObject]))
    {
        SaverWindow *saverWindow = NSMapGet(screensToWindows,key);
        [self stopTimer:[saverWindow contentView]];
        [saverWindow close];
        [screensToWindows removeObjectForKey:key];
    }
}

- (void) startSaver
{
    [self destroySaverWindow];
    [self createSaverWindow: NO];
    NSEnumerator *en = [screensToWindows keyEnumerator];
    NSDictionary *key = nil;
    
    while(nil != (key = [en nextObject]))
    {
        SaverWindow *saverWindow = [screensToWindows objectForKey:key];
        id module = [saverWindow contentView];
        [saverWindow setLevel: NSScreenSaverWindowLevel];
        [self startTimer:module];
        // [self stopTimer:module];
    }
}

- (void) stopSaver
{
    [self destroySaverWindow];
}

- (void) stopAndStartSaver
{
    [self stopSaver];
    [self doSaverInBackground: self];

    NSEnumerator *en = [screensToWindows keyEnumerator];
    NSDictionary *key = nil;
    while(nil != (key = [en nextObject]))
    {
        SaverWindow *saverWindow = [screensToWindows objectForKey:key];
        [saverWindow setLevel: NSDesktopWindowLevel];
        id module = [saverWindow contentView];
        [self startTimer:module];
    }
}

// timer managment
- (void) startTimer: (id)currentModule
{
    NSTimeInterval runSpeed = 0.05; //[speedSlider floatValue];
    NSTimeInterval time = runSpeed;
    NSTimer *timer = nil;
    
    NS_DURING
    {
        // Some modules may FORCE us to run at a given speed.
        if([currentModule respondsToSelector: @selector(animationDelayTime)])
        {
            time = [currentModule animationDelayTime];
        }
    }
    NS_HANDLER
    {
        NSLog(@"EXCEPTION: %@", localException);
        time = runSpeed;
    }
    NS_ENDHANDLER
    
    if(![currentModule respondsToSelector: @selector(isBoringScreenSaver)])
    {
        timer = [NSTimer scheduledTimerWithTimeInterval: time
                                                 target: self
                                               selector: @selector(runAnimation:)
                                               userInfo: currentModule
                                                repeats: YES];
    }
    else
    {
        // if the screen saver is "boring" it should only run oneStep
        // once.   This means that it will not waste CPU cycles spinning and
        // doing nothing...
        NS_DURING
        {
            // do one frame..
            [currentModule lockFocus];
            if([currentModule respondsToSelector: @selector(didLockFocus)])
            {
                [currentModule didLockFocus];
            }
            [currentModule oneStep];
            NSEnumerator *en = [screensToWindows keyEnumerator];
            NSDictionary *key = nil;
            
            [self stopTimer:currentModule];
            while(nil != (key = [en nextObject]))
            {
                SaverWindow *saverWindow = [screensToWindows objectForKey:key];
                [saverWindow setLevel: NSDesktopWindowLevel];
            }
            
            [currentModule unlockFocus];
        }
        NS_HANDLER
        {
            NSLog(@"EXCEPTION: %@",localException);
        }
        NS_ENDHANDLER
    }
    NSMapInsert(timersToModules, currentModule, timer);
}

- (void) stopTimer:(id)module
{
    NSTimer *timer = NSMapGet(timersToModules,module);
    if(timer != nil)
    {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
 
    if([module respondsToSelector:@selector(stopModule)])
    {
        [module stopModule];
    }
}

- (void) runAnimation: (NSTimer *)atimer
{
    NS_DURING
    {
        ModuleView *currentModule = (ModuleView *)[atimer userInfo];
        // do one frame..
        [currentModule lockFocus];
        if([currentModule respondsToSelector: @selector(didLockFocus)])
        {
            [currentModule didLockFocus];
        }
        [currentModule oneStep];
        [[currentModule window] flushWindow];
        [currentModule unlockFocus];
    }
    NS_HANDLER
    {
        NSLog(@"EXCEPTION while in running animation: %@",localException);
    }
    NS_ENDHANDLER;
}

- (NSMutableDictionary *) modules
{
    return modules;
}

- (void) findModulesInDirectory: (NSString *) directory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:directory
                                             error:NULL]; // directoryContentsAtPath: directory];
    NSEnumerator *en = [files objectEnumerator];
    id item = nil;
    
    NSLog(@"directory = %@",directory);
    while((item = [en nextObject]) != nil)
    {
        NSLog(@"file = %@",item);
        if([[item pathExtension] isEqualToString: @"InnerSpace"])
        {
            NSString *fullPath = [directory stringByAppendingPathComponent: item];
            NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
            
            [infoDict setObject: fullPath forKey: @"Path"];
            
            [modules setObject: infoDict forKey: [item stringByDeletingPathExtension]];
            NSLog(@"modules = %@",modules);
        }
    }
}

- (void) findModules
{
    // The directories...
    NSString *homeDir = NSHomeDirectory();
    NSString *resources = [[[[NSBundle mainBundle] bundlePath]
                            stringByAppendingPathComponent:@"Contents"]
                           stringByAppendingPathComponent:@"Resources"];
    NSString *gnustepLibraryInnerspace = [[[homeDir stringByAppendingPathComponent:@"GNUstep"]
                                           stringByAppendingPathComponent:@"Library"]
                                          stringByAppendingPathComponent:@"InnerSpace"];
    NSString *libraryInnerSpace = [[homeDir stringByAppendingPathComponent:@"Library"]
                                   stringByAppendingPathComponent:@"InnerSpace"];
    NSString *libraryApplicationSupport = [[[homeDir stringByAppendingPathComponent:@"Library"]
                                            stringByAppendingPathComponent:@"Application Support"]
                                           stringByAppendingPathComponent:@"InnerSpace"];
    
    // Find everything...
    [self findModulesInDirectory: resources];
    [self findModulesInDirectory: gnustepLibraryInnerspace];
    [self findModulesInDirectory: libraryInnerSpace];
    [self findModulesInDirectory: libraryApplicationSupport];
}

- (void) findModules: (NSTimer *)timer
{
    [self findModules];
}

- (void) _startModule: (ModuleView *)moduleView
{
    NS_DURING
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ISStateModuleNotification" object:self];
        [self createSaverWindow: YES];
        [self startTimer:moduleView];
    }
    NS_HANDLER
    {
        NSLog(@"EXCEPTION: %@",localException);
    }
    NS_ENDHANDLER;
}

- (void) _stopModule: (ModuleView *)moduleView
{
    NS_DURING
    {
        if([moduleView respondsToSelector: @selector(inspectorWillBeRemoved)])
        {
            [moduleView inspectorWillBeRemoved];
        }
        [self stopSaver];
    }
    NS_HANDLER
    {
        NSLog(@"EXCEPTION while in _stopModule: %@",localException);
    }
    NS_ENDHANDLER
    
    // Remove the view...
    // [(NSBox *)controlsView setContentView: emptyView];
    // [(NSBox *)controlsView setBorderType: NSGrooveBorder];
}

- (NSString *) _pathForModule: (NSString *) moduleName
{
    NSString *result = nil;
    NSMutableDictionary *dict;
    
    if((dict = [modules objectForKey: moduleName]) != nil)
    {
        result = [dict objectForKey: @"Path"];
    }
    return result;
}

- (id)loadModule:(NSString *)moduleName forScreen:(NSScreen *)screen
{
    id newModule = nil;
    
    if(moduleName)
    {
        NSBundle *bundle = nil;
        Class    theViewClass;
        NSString *bundlePath = [self _pathForModule: moduleName];
        
        NSLog(@"Bundle path = %@",bundlePath);
        bundle = [NSBundle bundleWithPath: bundlePath];
        if(bundle != nil)
        {
            NSLog(@"Bundle loaded");
            theViewClass = [bundle principalClass];
            if(theViewClass != nil)
            {
                newModule = [[theViewClass alloc] initWithFrame: [screen frame]];
            }
        }
    }

    if(newModule)
    {
        // [self createSaverWindow: newModule];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ISModuleChangedNotification"
                                                            object:self];
    }
    
    return newModule;
}

- (IBAction)showPreferencePanels:(id)sender
{
    NSArray *screens = [NSScreen screens];

    for(NSScreen *screen in screens)
    {
        PreferencesPanelController *controller = [[PreferencesPanelController alloc] init];
        
        [controller setParentController:self];
        
        [NSBundle loadNibNamed:@"PreferencesPanel"
                         owner:controller];
        [controllers addObject:controller];
        [controller release];
    }
}

- (void) closeAllPreferencesPanels
{
    [controllers removeAllObjects];
}

@end

