@import <AppKit/CPView.j>
@import <AppKit/CPCollectionView.j>
@import <AppKit/CPScrollView.j>
@import "ArtworkView.j"
@import "RLOfflineLocalStorage.j"

var GRID_SIZE = 240.0;
var TOOL_HEIGHT = 30.0;
var TOOL_MARGIN = 24.0;
var SEP_WIDTH = 10.0;
var SORT_TITLES = ["Date ▼", "Date ▲", "Votes ▼", "Votes ▲", "Views ▼", "Views ▲"];

// -created_at, created_at, -vote_count, vote_count, -view_count, view_count
var SORT_FUNCTIONS = [
    function(a, b) {return b["created_at"] - a["created_at"]},
    function(a, b) {return a["created_at"] - b["created_at"]},
    function(a, b) {return b["vote_count"] - a["vote_count"]},
    function(a, b) {return a["vote_count"] - b["vote_count"]},
    function(a, b) {return b["view_count"] - a["view_count"]},
    function(a, b) {return a["view_count"] - b["view_count"]},
];

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

        var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, TOOL_HEIGHT, w, h - TOOL_MARGIN)];
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

- (void)loadFromLocalStorage
{
    var content = [],
        i = 0,
        storage = [RLOfflineLocalStorage sharedOfflineLocalStorage],
        value = nil,
        count = nil,
        view_count = nil,
        vote_count = nil,
        created_at = nil,
        updated_at = nil;

    value = [storage getValueForKey:@"artworks.count"];
    count = value && parseInt(value) || 0;

    for (i = 0; i < count; i++)
    {
        value = [storage getValueForKey:@"artworks[" + i + "].view_count"];
        view_count = value && parseInt(value) || 0;
        value = [storage getValueForKey:@"artworks[" + i + "].vote_count"];
        vote_count = value && parseInt(value) || 0;
        value = [storage getValueForKey:@"artworks[" + i + "].created_at"];
        created_at = value && parseInt(value) || 0;
        value = [storage getValueForKey:@"artworks[" + i + "].updated_at"];
        updated_at = value && parseInt(value) || 0;

        content[i] = {
            name: [storage getValueForKey:@"artworks[" + i + "].name"] || "",
            email: [storage getValueForKey:@"artworks[" + i + "].email"] || "",
            created_at: created_at,
            updated_at: updated_at,
            view_count: view_count,
            vote_count: vote_count,
            image: [storage getValueForKey:@"artworks[" + i + "].image"] || "",
            thumbnail: [storage getValueForKey:@"artworks[" + i + "].thumbnail"] || "",
            id: [storage getValueForKey:@"artworks[" + i + "].thumbnail"] || "",
            image_url: [storage getValueForKey:@"artworks[" + i + "].image_url"] || "",
            thumbnail_url: [storage getValueForKey:@"artworks[" + i + "].thumbnail_url"] || "",
        };
    }

    content.sort(SORT_FUNCTIONS[_sortBy] || SORT_FUNCTIONS[0]);
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

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    if (connection == _conn)
    {
        if (200 != [response statusCode])
        {
            // TODO: show failed message.
            [connection cancel];
            _conn = nil;

            // FIXME: Not neccessary correct to fallback to local storage!
            [self loadFromLocalStorage];
        }
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (connection == _conn)
    {
        [self loadFromJson:data];
        _conn = nil;
    }
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    // TODO: show failed message.
    _conn = nil;

    // FIXME: Not neccessary correct to fallback to local storage!
    [self loadFromLocalStorage];
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
