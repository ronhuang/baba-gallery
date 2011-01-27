@import <AppKit/CPView.j>
@import <AppKit/CPCollectionView.j>
@import <AppKit/CPScrollView.j>
@import "ArtworkView.j"

var MENU_HEIGHT = 30.0;
var GRID_SIZE = 240.0;

@implementation GalleryView : CPView
{
    CPCollectionView _artworksView;
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

        /* Test */
        var cb = function() {
            var jsonString = @"{\"status\": 200, \"count\": 2, \"content\": [{\"name\": \"Ron Huang\", \"email\": \"a@a.org\", \"vote_count\": 3, \"image_url\": \"/artwork/1/image\"}, {\"name\": \"Darth Feces\", \"email\": \"b@b.org\", \"vote_count\": 6, \"image_url\": \"/artwork/2/image\"}]}";
            [self loadFromJson:jsonString];
        };
        timer = [CPTimer scheduledTimerWithTimeInterval:1 callback:cb repeats:NO];
    }

    return self;
}

- (void)loadFromJson:(CPString)jsonString
{
    var jsObject = [jsonString objectFromJSON];
    [_artworksView setContent:jsObject["content"]];
}

@end
