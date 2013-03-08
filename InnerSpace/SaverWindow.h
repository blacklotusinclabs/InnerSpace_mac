/* All Rights reserved */

#import <AppKit/AppKit.h>

#ifndef GNUSTEP
#define NSDesktopWindowLevel (CGWindowLevelForKey(kCGDesktopIconWindowLevelKey) - 1)
#endif


@interface SaverWindow : NSWindow
{
  id  target;
  SEL action;
}
- (void) setAction: (SEL)action forTarget: (id) target;
@end
