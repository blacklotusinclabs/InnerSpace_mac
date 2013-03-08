
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SporView:NSView
{
	id	inspector;
	id	startPop;
	id	maxPop;
	id	startSpread;
	id	startCloud;
	id	kindRadio;
	id	eatRadio;
	id	sporWindow;

	NSInteger	kind,
			enemy,
			pop,
			sPop,
			spread,
		 	cloud;
	BOOL	initDone,
				inspectorPresent;

}

- oneStep;
- (id) initWithFrame:( NSRect )frameRect;
- (id) drawRect:(NSRect)rects;
/// - sizeToFit:(NSSize)size;

- (id)inspectorInstalled;
- (id)inspectorWillBeRemoved;
- inspector: sender;

- toggleKind:sender;
- toggleEnemy:sender;

- getStartParameter;
- showStartParameter;
- ( NSInteger )setRangeForValue:( NSInteger )aValue Low:( NSInteger )low High:( NSInteger )high;

@end
