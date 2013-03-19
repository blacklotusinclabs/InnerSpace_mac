//
//  ScreensView.h
//  InnerSpace
//
//  Created by Gregory Casamento on 3/14/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *ScreensViewSelectedScreenNotification;

@interface ScreensView : NSView
{
}

- (void)screenSelected:(id)sender;

@end
