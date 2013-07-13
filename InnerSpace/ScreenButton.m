//
//  ScreenButton.m
//  InnerSpace
//
//  Created by Gregory Casamento on 3/14/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import "ScreenButton.h"
#import <IOKit/graphics/IOGraphicsLib.h>

static void KeyArrayCallback(const void* key, const void* value, void* context) { CFArrayAppendValue(context, key);  }

@implementation ScreenButton

@synthesize isSelected = isSelected;

+ (NSString*)localizedScreenName:(NSScreen *)screen
{
    NSDictionary* screenDictionary = [screen deviceDescription];
    NSNumber* screenID = [screenDictionary objectForKey:@"NSScreenNumber"];
    CGDirectDisplayID aID = [screenID unsignedIntValue];
    CFStringRef localName = NULL;
    io_connect_t displayPort = CGDisplayIOServicePort(aID);
    CFDictionaryRef dict = (CFDictionaryRef)IODisplayCreateInfoDictionary(displayPort, 0);
    CFDictionaryRef names = CFDictionaryGetValue(dict, CFSTR(kDisplayProductName));
    if(names)
    {
    	//CFArrayRef langKeys = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks );
    	//CFDictionaryApplyFunction(names, KeyArrayCallback, (void*)langKeys);
    	//CFArrayRef orderLangKeys = CFBundleCopyPreferredLocalizationsFromArray(langKeys);
    	//CFRelease(langKeys);
    	//if(orderLangKeys && CFArrayGetCount(orderLangKeys))
    	{
    		CFStringRef langKey = CFStringCreateWithCString(kCFAllocatorDefault, "en_US", kCFStringEncodingASCII); 
    		localName = CFDictionaryGetValue(names, langKey);
    		CFRetain(localName);
    	}
    	//CFRelease(orderLangKeys);
    }
    CFRelease(dict);
    return [(NSString*)localName autorelease];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithScreen:(NSScreen *)screen
{
    NSRect newFrame = [screen frame];
    newFrame.size.height = newFrame.size.height * 0.1;
    newFrame.size.width = newFrame.size.width * 0.1;
    newFrame.origin.x = newFrame.origin.x * 0.1;
    newFrame.origin.y = newFrame.origin.y * 0.1;// + 10;
    
    if(nil != ([self initWithFrame:newFrame]))
    {
        NSString *screenName = [ScreenButton localizedScreenName:screen];
        screen_ = screen;
        [self setTitle:screenName];
        [self setButtonType:NSPushOnPushOffButton];
        [self setBordered:YES];
        //[self setBezelStyle:NSLineBorder];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    if(isSelected)
    {
        [[NSColor redColor] set];
        NSFrameRectWithWidth(dirtyRect, 3.0);
    }
    //[[NSColor blueColor] set];
    //NSRectFill(dirtyRect);
    //[[NSColor blackColor] set];
    //NSDrawGroove(dirtyRect, NSZeroRect);
}

- (NSScreen *)screen
{
    return screen_;
}
@end
