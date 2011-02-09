/*
 * AppController.j
 * web
 *
 * Created by Ron Huang on January 26, 2011.
 * Copyright 2011, Ron Huang All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPWebView.j>
@import "GalleryView.j"
@import "ContributeView.j"

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    var tabView = [[CPTabView alloc] initWithFrame:[contentView frame]];
    [tabView setTabViewType:CPTopTabsBezelBorder];
    [tabView layoutSubviews];
    [tabView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];

    var homeItem = [[CPTabViewItem alloc] initWithIdentifier:@"home"];
    [homeItem setLabel:@"Home"];
    var homeView = [[CPWebView alloc] initWithFrame:CPRectMakeZero()];
    var mainBundle = [CPBundle mainBundle];
    [homeView setMainFrameURL:[mainBundle pathForResource:@"home.html"]];
    [homeItem setView:homeView];
    [tabView addTabViewItem:homeItem];

    var galleryItem = [[CPTabViewItem alloc] initWithIdentifier:@"gallery"];
    [galleryItem setLabel:"Gallery"];
    var galleryView = [[GalleryView alloc] initWithFrame:CPRectMakeZero()];
    [galleryItem setView:galleryView];
    [tabView addTabViewItem:galleryItem];

    var contributeItem = [[CPTabViewItem alloc] initWithIdentifier:@"contribute"];
    [contributeItem setLabel:"Contribute"];
    var contributeView = [[ContributeView alloc] initWithFrame:CPRectMakeZero()];
    [contributeItem setView:contributeView];
    [tabView addTabViewItem:contributeItem];

    [contentView addSubview:tabView];

    /* Test */
    [tabView selectTabViewItemAtIndex:2];
    CPLogRegister(CPLogConsole);

    [theWindow orderFront:self];
}

@end
