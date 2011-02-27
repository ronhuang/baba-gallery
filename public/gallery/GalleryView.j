@import <AppKit/CPView.j>
@import <AppKit/CPCollectionView.j>
@import <AppKit/CPScrollView.j>
@import "ArtworkView.j"

var GRID_SIZE = 240.0;

@implementation GalleryView : CPView
{
    CPCollectionView _artworksView;
    CPURLConnection _conn;
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

        var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, w, h)];
        [scrollView setDocumentView:_artworksView];
        [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [scrollView setAutohidesScrollers:YES];

        [self addSubview:scrollView];

        [self fetchData];
    }

    return self;
}

- (void)loadFromJson:(CPString)jsonString
{
    var jsObject = [jsonString objectFromJSON],
        content = jsObject["content"];

    if ([_artworksView items].length != content.length)
        [_artworksView setContent:content];
}

- (void)fetchData
{
    if (_conn)
        return;

    var req = [CPURLRequest requestWithURL:@"/artworks"];
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

@end
