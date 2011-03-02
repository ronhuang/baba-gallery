/*
 * AppController.j
 * Baba Painter
 *
 * Created by Ron Huang on January 26, 2011.
 * Copyright 2011, Ron Huang All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "ContributeView.j"
@import "GalleryView.j"

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView],
        args = [CPApp arguments],
        appName = args[0],
        appView = nil;

    if ("painter" == appName)
        appView = [[ContributeView alloc] initWithFrame:[contentView frame]];
    else if ("gallery" == appName)
        appView = [[GalleryView alloc] initWithFrame:[contentView frame]];
    else
    {
        CPLog.error(@"Unknown application: %s", appName);
        appView = [[ContributeView alloc] initWithFrame:[contentView frame]];
    }

    [appView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
    [contentView addSubview:appView];

    [theWindow orderFront:self];
}

@end
