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
    if (self) {
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
}
@end
