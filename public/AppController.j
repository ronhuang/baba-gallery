/*
 * AppController.j
 * Baba Painter
 *
 * Created by Ron Huang on January 26, 2011.
 * Copyright 2011, Ron Huang All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPWebView.j>
@import "HomeView.j"
@import "GalleryView.j"
@import "ContributeView.j"

TAB_MARGIN = 15.0;

@implementation AppController : CPObject
{
    CPTabViewItem _galleryItem;
    CPView _galleryView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    var tabView = [[CPTabView alloc] initWithFrame:[contentView frame]];
    [tabView setTabViewType:CPTopTabsBezelBorder];
    [tabView layoutSubviews];
    [tabView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
    [tabView setDelegate:self];

    var homeItem = [[CPTabViewItem alloc] initWithIdentifier:@"home"];
    [homeItem setLabel:@"Home"];
    var homeView = [[HomeView alloc] initWithFrame:CPRectMakeZero()];
    [homeItem setView:homeView];
    [tabView addTabViewItem:homeItem];

    _galleryItem = [[CPTabViewItem alloc] initWithIdentifier:@"gallery"];
    [_galleryItem setLabel:"Gallery"];
    _galleryView = [[GalleryView alloc] initWithFrame:CPRectMakeZero()];
    [_galleryItem setView:_galleryView];
    [tabView addTabViewItem:_galleryItem];

    var contributeItem = [[CPTabViewItem alloc] initWithIdentifier:@"contribute"];
    [contributeItem setLabel:"Contribute"];
    var contributeView = [[ContributeView alloc] initWithFrame:CPRectMakeZero()];
    [contributeItem setView:contributeView];
    [tabView addTabViewItem:contributeItem];

    [contentView addSubview:tabView];

    /* Test */
    [tabView selectTabViewItemAtIndex:0];
    CPLogRegister(CPLogConsole);

    [theWindow orderFront:self];
}

- (void) tabView:(CPTabView)aView didSelectTabViewItem:(CPTabViewItem)anItem
{
    if (anItem == _galleryItem)
    {
        [_galleryView fetchData];
    }
}

@end
