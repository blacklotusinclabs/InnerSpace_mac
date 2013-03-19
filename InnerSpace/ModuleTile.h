//
//  ModuleTile.h
//  InnerSpace
//
//  Created by Gregory Casamento on 3/18/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ModuleTile : NSObject
{
    NSImage *image;
    NSString *moduleName;
}

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSString *moduleName;

@end
