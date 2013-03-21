//
//  ModuleTileView.m
//  InnerSpace
//
//  Created by Gregory Casamento on 3/19/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import "ModuleTileView.h"

@implementation ModuleTileView

@synthesize selected;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect outerFrame = dirtyRect;
    NSRect selectedFrame = NSInsetRect(outerFrame, 2, 2);

    if(selected)
    {
        [[NSColor redColor] set];
    }
    else
    {
        [[NSColor whiteColor] set];
    }
    
    [NSBezierPath strokeRect:selectedFrame];
}

- (void)awakeFromNib
{
    imageView.wantsLayer = YES;
    imageView.layer.cornerRadius = 10;
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2;
    shadow.shadowOffset = NSMakeSize(4, -4);
    shadow.shadowColor = [NSColor blackColor];
    imageView.shadow = shadow;
}

@end
