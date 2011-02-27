@import <AppKit/CPView.j>
@import <AppKit/CPCollectionView.j>
@import <AppKit/CPScrollView.j>
@import "ArtworkView.j"

var GRID_SIZE = 240.0;
var TOOL_HEIGHT = 30.0;
var TOOL_MARGIN = 24.0;
var SEP_WIDTH = 10.0;
var SORT_TITLES = ["Date ▼", "Date ▲", "Votes ▼", "Votes ▲"];

@implementation GalleryView : CPView
{
    CPCollectionView _artworksView;
    CPURLConnection _conn;

    CPPopUpButton _menu;
    int _sortBy;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        var bounds = [self bounds];

        var w = CGRectGetWidth(bounds);
        var h = CGRectGetHeight(bounds);
        _artworksView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, w, h)];
        [_artworksView setAutoresizingMask:CPViewWidthSizable];
        [_artworksView setMinItemSize:CGSizeMake(GRID_SIZE, GRID_SIZE)];
        [_artworksView setMaxItemSize:CGSizeMake(GRID_SIZE, GRID_SIZE)];

        var itemPrototype = [[CPCollectionViewItem alloc] init],
            aView = [[ArtworkView alloc] initWithFrame:CGRectMake(0.0, 0.0, GRID_SIZE, GRID_SIZE)];
        [itemPrototype setView:aView];
        [_artworksView setItemPrototype:itemPrototype];

        var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, TOOL_HEIGHT, w, h)];
        [scrollView setDocumentView:_artworksView];
        [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [scrollView setAutohidesScrollers:YES];
        [self addSubview:scrollView];

        /* Tool */
        var w = 100.0;
        var refreshBtn = [CPButton buttonWithTitle:@"Refresh"];
        [refreshBtn setFrame:CGRectMake(CGRectGetWidth(bounds) - TOOL_MARGIN - w - SEP_WIDTH - w, 0.0, w, 24.0)];
        [refreshBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
        [refreshBtn setTarget:self];
        [refreshBtn setAction:@selector(fetchData)];
        [self addSubview:refreshBtn];

        _sortBy = 0;
        _menu = [[CPPopUpButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(bounds) - TOOL_MARGIN - w, 0.0, w, 24.0) pullsDown:NO];
        [_menu setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
        for (var i = 0; i < [SORT_TITLES count]; i++)
        {
            var item = [[CPMenuItem alloc] initWithTitle:SORT_TITLES[i] action:@selector(itemSelected) keyEquivalent:nil];
            [item setTarget:self];
            [item setTag:i];
            [_menu addItem:item];
        }
        [_menu setTitle:@"Sort by"];
        [self addSubview:_menu];

        /* Should I fetch data this early? */
        [self fetchData];
    }

    return self;
}

- (void)loadFromJson:(CPString)jsonString
{
    var jsObject = [jsonString objectFromJSON],
        content = jsObject["content"];

    [_artworksView setContent:content];
}

- (void)fetchData
{
    if (_conn)
        return;

    var url = [CPString stringWithFormat:@"/artworks?sort_by=%d", _sortBy];
    var req = [CPURLRequest requestWithURL:url];
    _conn = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    _conn = nil;
    [self loadFromJson:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    // TODO: show failed message.
    _conn = nil;
}

- (void)itemSelected
{
    var item = [_menu selectedItem];
    var idx = [item tag];

    if (_sortBy == idx)
        return;

    _sortBy = idx;

    [self fetchData];
}

@end
