/*
 * AppController.j
 * Baba Painter
 *
 * Created by Ron Huang on January 26, 2011.
 * Copyright 2011, Ron Huang All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "ContributeView.j"

TAB_MARGIN = 15.0;

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    var contributeView = [[ContributeView alloc] initWithFrame:[contentView frame]];
    [contributeView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
    [contentView addSubview:contributeView];

    [theWindow orderFront:self];
}

@end
