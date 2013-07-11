//
//  PreferencesPanelCellViewController.h
//  InnerSpace
//
//  Created by Gregory Casamento on 7/10/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesPanelCellViewController : NSViewController
{
    IBOutlet NSImageView *image;
    IBOutlet NSTextField *description;
}

@property (nonatomic,readonly) IBOutlet NSImageView *image;
@property (nonatomic,readonly) IBOutlet NSTextField *description;

@end
