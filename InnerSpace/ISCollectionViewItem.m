//
//  ISCollectionViewItem.m
//  InnerSpace
//
//  Created by Gregory Casamento on 3/19/13.
//  Copyright (c) 2013 Open Logic Corporation. All rights reserved.
//

#import "ISCollectionViewItem.h"
#import "ModuleTileView.h"

@interface ISCollectionViewItem ()

@end

@implementation ISCollectionViewItem

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    ModuleTileView *tileView = (ModuleTileView *)[self view];
    [tileView setSelected:selected];
    [tileView setNeedsDisplay:YES];
}

@end
