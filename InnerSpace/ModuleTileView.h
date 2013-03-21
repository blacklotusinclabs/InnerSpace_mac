//
//  ModuleTileView.h
//  InnerSpace
//
//  Created by Gregory Casamento on 3/19/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ModuleTileView : NSView
{
    BOOL selected;
    IBOutlet NSImageView *imageView;
    IBOutlet NSTextField *textField;
}

@property (readwrite) BOOL selected;

@end
