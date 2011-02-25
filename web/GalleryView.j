@import <AppKit/CPView.j>
@import <AppKit/CPCollectionView.j>
@import <AppKit/CPScrollView.j>
@import "ArtworkView.j"

var MENU_HEIGHT = 30.0;
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

        var descLabel = [[CPTextField alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(bounds), MENU_HEIGHT)];
        [descLabel setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin];
        [descLabel setStringValue:@"Short description."];
        [descLabel setFont:[CPFont boldSystemFontOfSize:24.0]];
        [self addSubview:descLabel];


        var w = CGRectGetWidth(bounds);
        var h = CGRectGetHeight(bounds) - MENU_HEIGHT;
        _artworksView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, MENU_HEIGHT, w, h)];
        [_artworksView setAutoresizingMask:CPViewWidthSizable];
        [_artworksView setMinItemSize:CGSizeMake(GRID_SIZE, GRID_SIZE)];
        [_artworksView setMaxItemSize:CGSizeMake(GRID_SIZE, GRID_SIZE)];

        var itemPrototype = [[CPCollectionViewItem alloc] init],
            aView = [[ArtworkView alloc] initWithFrame:CGRectMake(0.0, 0.0, GRID_SIZE, GRID_SIZE)];
        [itemPrototype setView:aView];
        [_artworksView setItemPrototype:itemPrototype];

        var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, MENU_HEIGHT, w, h)];
        [scrollView setDocumentView:_artworksView];
        [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [scrollView setAutohidesScrollers:YES];

        [self addSubview:scrollView];
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
