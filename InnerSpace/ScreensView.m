//
//  ScreensView.m
//  InnerSpace
//
//  Created by Gregory Casamento on 3/14/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import "ScreensView.h"
#import "ScreenButton.h"

NSString *ScreensViewSelectedScreenNotification = @"ScreensViewSelectedScreenNotification";

@implementation ScreensView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        CGFloat xpos = 0.0;
        CGFloat totalWidth = 0.0;
        
        // Initialization code here.
        NSArray *screenArray = [NSScreen screens];
        for(NSScreen *screen in screenArray)
        {
            totalWidth += [screen frame].size.width * 0.1;
        }
        
        xpos = (frame.size.width - totalWidth)/2.0;
        
        NSInteger index = 0;
        for(NSScreen *screen in [screenArray reverseObjectEnumerator])
        {
            ScreenButton *button = [[ScreenButton alloc] initWithScreen:screen];
            NSRect frame = [button frame];

            frame.origin.y += 20;
            frame.origin.x = xpos;
            [button setFrame:frame];
            [self addSubview:button];
            xpos += frame.size.width;
            
            [button setTarget:self];
            [button setAction:@selector(screenSelected:)];
            [button setTag:index];
            index++;
        }
    }
    return self;
}

- (void)awakeFromNib
{
    // Select first view...
    ScreenButton *button = (ScreenButton *)[[self subviews] objectAtIndex:0];
    [button performSelector:@selector(performClick:)
                 withObject:self
                 afterDelay:(NSTimeInterval)0.5];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor lightGrayColor] set];
    NSRectFill(dirtyRect);
    [[NSColor blackColor] set];
    NSDrawGroove(dirtyRect, NSZeroRect);
}

- (void)screenSelected:(id)sender
{
    NSDictionary *info = [[sender screen] deviceDescription];
    NSLog(@"%@",sender);
    [[NSNotificationCenter defaultCenter] postNotificationName:ScreensViewSelectedScreenNotification
                                                        object:sender
                                                      userInfo:info];
    
    [sender setIsSelected:YES]; // setBackgroundColor:[NSColor orangeColor]];
    NSArray *subviews = [self subviews];
    for(ScreenButton *button in subviews)
    {
        if(button != sender)
        {
            [button setIsSelected:NO];
        }
    }
    [self setNeedsDisplay:YES];
}
@end
