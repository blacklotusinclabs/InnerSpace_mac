//
//  PSOperators.m
//  InnerSpace
//
//  Created by Gregory Casamento on 1/30/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import "PSOperators.h"

static PSOperators *instance_ = nil;

@implementation PSOperators
+ (id)sharedInstance
{
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        instance_ = [[PSOperators alloc] init];
    });
    return instance_;
}

- (id)init
{
    if(nil != (self = [super init]))
    {
        context_ = [NSGraphicsContext currentContext];
        currentPath_ = nil; //[[NSBezierPath alloc] init];
    }
    return self;
}

- (void)createPath
{
    if(nil == currentPath_)
    {
        currentPath_ = [[NSBezierPath alloc] init];
    }
}

- (void)destroyPath
{
    [currentPath_ release];
    currentPath_ = nil;
    currentPath_ = [[NSBezierPath alloc] init];    
}

- (void)PSlineto:(float)x :(float)y
{
    [self createPath];
    [currentPath_ lineToPoint:NSMakePoint(x, y)];
}

- (void)PSmoveto:(float)x :(float)y
{
    [self createPath];
    [currentPath_ moveToPoint:NSMakePoint(x, y)];
}

- (void)PSsetrgbcolor:(float)r :(float)g :(float)b
{
    NSColor *theColor = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0];
    [theColor set];
}

- (void)PSsetgray:(float)v
{
    NSColor *theColor = [NSColor colorWithCalibratedWhite:v alpha:1.0];
    [theColor set];    
}

- (void)PSfill
{
    [currentPath_ fill];
    [self destroyPath];
}

- (void)PSstroke
{
    [currentPath_ stroke];
    [self destroyPath];
}

- (void)PSsetlinewidth:(float)w
{
    [currentPath_ setLineWidth:w];
}

- (void)PSclosepath
{
    [currentPath_ closePath];
    [self destroyPath];
}

- (void)PSnewpath
{
    [self createPath];
}
@end

void PSlineto(float x, float y)
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSlineto:x :y];
}

void PSmoveto(float x, float y)
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSmoveto:x :y];
}

void PSsetrgbcolor(float r, float g, float b)
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSsetrgbcolor:r :g :b];
}

void PSsetgray(float v)
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSsetgray:v];
}

void PSsetlinewidth(float w)
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSsetlinewidth:w];
}

void PSfill()
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSfill];
}

void PSstroke()
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSstroke];
}

void PSclosepath()
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSclosepath];
}

void PSnewpath()
{
    PSOperators *ops = [PSOperators sharedInstance];
    [ops PSnewpath];
}
