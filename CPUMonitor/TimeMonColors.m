// Copyright 1994, 1997 Scott Hess.  Permission to use, copy, modify,
// and distribute this software and its documentation for any
// purpose and without fee is hereby granted, provided that this
// copyright notice appear in all copies.
// 
// Scott Hess makes no representations about the suitability of
// this software for any purpose.  It is provided "as is" without
// express or implied warranty.
//
#import "TimeMonColors.h"
#import "TimeMonWraps.h"
#import "NSColorExtensions.h"

@interface NSTextFieldCell (TimeMonTextFieldCell)
- (void)setColor:(NSColor *)color;
@end

@implementation TimeMonColors
// Have to set up the cells and stuff manually since we're a
// custom view.
- (id)initWithFrame:(NSRect)frameRect
{
  self = [super initWithFrame:frameRect mode:0 cellClass:[NSTextFieldCell class] numberOfRows:1 numberOfColumns:4];
  if (self) 
    {
      NSSize size = { 1, frameRect.size.height};
      [self setIntercellSpacing:size];
      size.width = ((int)frameRect.size.width-3)/4;
      [self setCellSize:size];
      [self setAutosizesCells:YES];
      [[self window] setAcceptsMouseMovedEvents:YES];
      [self registerForDraggedTypes:[NSArray arrayWithObject:NSColorPboardType]];
    }
  return self;
}

- (BOOL)isFlipped
{
    return NO;
}

static const id titles[] = {
    @"Idle", @"Nice", @"User", @"System",
};

// Read the colors for each field and stuff them into it.
- (void)readColors
{
    int i;
    BOOL shouldDrawColor = [self shouldDrawColor];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for(i = 0; i < 4; i++) {
        NSTextFieldCell *tCell = [self cellAtRow:0 column:i];
        [tCell setStringValue:titles[ i]];
	// If self is in a color window, then load color
	// information.
        if (shouldDrawColor) 
	  {
            NSString *key = [NSString stringWithFormat:@"%@Color",titles[i]];
            NSString *string = [defaults objectForKey:key];
            [tCell setColor:[NSColor colorFromStringRepresentation:string]];
	    
            // Otherwise, load grayscale information.
	  } 
	else 
	  {
            NSString *key = [NSString stringWithFormat:@"%@Gray",titles[i]];
            float color = [defaults floatForKey:key];
            [tCell setColor:[NSColor colorWithCalibratedWhite:color alpha:1.0]];
	  }
        [tCell setBezeled:YES];
        [tCell setAlignment:NSCenterTextAlignment];
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)theEvent
{
    return YES;
}

// Intercept the mousedown and cause it to drag a color.  If
// double-click, pull up the color panel.
- (void)mouseDown:(NSEvent *)e 
{
    NSPoint loc = [e locationInWindow];
    int row, col;
    NSColor * color;
    
    // Find the color of the cell the click is in.
    loc = [self convertPoint:loc fromView:nil];
    [self getRow:&row column:&col forPoint:loc];
    color = [[self cellAtRow:row column:col] backgroundColor];
    
    // If it's a double-click, load the color into the color
    // panel and bring that panel up.
    if ([e clickCount] > 1 && ![NSColorPanel sharedColorPanelExists]) 
      {
        id newVar = [NSColorPanel sharedColorPanel];
        [newVar setColor:color];
        [newVar orderFront:nil];
      }
    else 
      {
        NSEvent *theEvent = e;
	
        // Get the next mouse up or dragged event.
        e = [[self window] nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)];
	
        // If it was a drag, initiate the color drag from
        // ourselves.
        if (e) 
	  {
            if ([e type] == NSLeftMouseDragged) 
	      {
		[NSColorPanel dragColor:color withEvent:theEvent fromView:self];
	      }
	  }
      }
}

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;

    pboard = [sender draggingPasteboard];
    if ([[pboard types] indexOfObject:NSColorPboardType] != NSNotFound) 
      {
        return NSDragOperationAll;
      }
    return NSDragOperationNone;
}

- (unsigned int)draggingSourceOperationMaskForLocal: (BOOL)isLocal
{
  return NSDragOperationGeneric;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    int row, col;
    NSPoint loc = [sender draggingLocation];
    NSTextFieldCell *tCell;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSColor *color = nil;

    if ([[pasteboard types] containsObject:NSColorPboardType]) 
      {
        color = [NSColor colorFromPasteboard:pasteboard];
      }
    else 
      {
        NSLog(@"No color");
        return NO;
      }

    // Find the cell for the point.
    loc = [self convertPoint:loc fromView:nil];
    [self getRow:&row column:&col forPoint:loc];
    tCell = [self cellAtRow:row column:col];

    // Set the color for the cell and redraw it.
    [tCell setColor:color];
    [self lockFocus];
    [self drawCellInside:tCell];
    [[self window] flushWindow];
    [self unlockFocus];

    // If self is in a color window, save color information.
    if ([self shouldDrawColor]) 
      {
        NSString *key = [NSString stringWithFormat:@"%@Color",titles[col]];
        [defaults setObject:[color stringRepresentation] forKey:key];
	// Otherwise, save grayscale information.
      } 
    else 
      {
        float gray, alpha;
        NSString *key = [NSString stringWithFormat:@"%@Gray",titles[col]];
        [[color colorUsingColorSpaceName:NSCalibratedWhiteColorSpace] getWhite:&gray alpha:&alpha];
        [defaults setFloat:gray forKey:key];
      }
    [defaults synchronize];
    
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
  [[NSApp delegate] display];
}
@end

@implementation NSTextFieldCell (TimeMonTextFieldCell)
// Set the colors for the field.  Adjust the foreground color
// so that it's visible against the background.
- (void)setColor:(NSColor *)color
{
    float gray;
    float r, g, b;
    
    // Remove any alpha component.
    color = [color colorWithAlphaComponent:1.0];
    
    // Get the grayscale version.
    gray = [[color colorUsingColorSpaceName:NSCalibratedWhiteColorSpace] whiteComponent];
    
    // Set the text to be visible.
    [self setTextColor:[NSColor colorWithCalibratedWhite:(gray < 0.33 ? NSWhite : NSBlack) alpha:1.0]];
    
    // Set the color and gray for the field.
    [self setBackgroundColor:color];
    
    // Tell the windowserver code that we want to use this
    // color for drawing the appropriate element.  [Note that
    // stringValue should be one of "Idle", "Nice", "User", or
    // "System".]
    [[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:NULL];
}
@end

