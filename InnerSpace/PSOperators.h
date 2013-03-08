//
//  PSOperators.h
//  InnerSpace
//
//  Created by Gregory Casamento on 1/30/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//
/*
 Copyright (c) 2012 Gregory John Casamento
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
 EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
 THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// Functions...
void PSlineto(float x, float y);
void PSmoveto(float x, float y);
void PSsetrgbcolor(float r, float g, float b);
void PSsetgray(float v);
void PSsetlinewidth(float w);
void PSfill();
void PSstroke();
void PSclosepath();
void PSnewpath();

// Class...
@interface PSOperators : NSObject
{
    NSGraphicsContext *context_;
    NSBezierPath *currentPath_;
}
- (void)PSlineto:(float)x :(float)y;
- (void)PSmoveto:(float)x :(float)y;
- (void)PSsetrgbcolor:(float)r :(float)g :(float)b;
- (void)PSsetgray:(float)v;
- (void)PSfill;
- (void)PSstroke;
- (void)PSsetlinewidth:(float)w;
- (void)PSclosepath;
- (void)PSnewpath;
@end
