//
//  ScreenButton.h
//  InnerSpace
//
//  Created by Gregory Casamento on 3/14/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScreenButton : NSButton
{
    NSScreen *screen_;
    BOOL isSelected;
}

@property (nonatomic,assign) BOOL isSelected;

- (id) initWithScreen:(NSScreen *)screen;
- (NSScreen *)screen;

@end
