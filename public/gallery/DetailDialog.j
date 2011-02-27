@import <AppKit/CPPanel.j>
@import <AppKit/CPWindowController.j>

var MARGIN_SIZE = 15.0;

@implementation DetailDialog : CPWindowController
{
    CPWindow _window;
    id _artwork;
}

- (id)initWithFrame:(CGRect)aFrame artwork:(id)anArtwork
{
    _window = [[CPPanel alloc] initWithContentRect:aFrame styleMask:CPBorderlessWindowMask];
    _artwork = anArtwork;

    self = [super initWithWindow:_window];

    if (self)
    {
        var contentView = [_window contentView],
            bounds = [contentView bounds],
            maxX = CGRectGetWidth(bounds),
            maxY = CGRectGetHeight(bounds);

        // Background
        var borderLayer = [CALayer layer];
        [borderLayer setDelegate:self];
        [borderLayer setNeedsDisplay];
        [borderLayer setZPosition:-1.0];
        [contentView setWantsLayer:YES];
        [contentView setLayer:borderLayer];

        var info = [CPString stringWithFormat:@"ID: %d\nVotes: %d\nViewed: %d\nCreated: %s",
                             _artwork["id"], _artwork["vote_count"], _artwork["view_count"], _artwork["created_at"]];
        var label = [self labelWithTitle:info];
        var lblFrame = [label frame];
        var x = (maxX - CGRectGetWidth(lblFrame)) / 2.0;
        var y = maxY - CGRectGetHeight(lblFrame) - MARGIN_SIZE;
        [label setFrame:CGRectMake(x, y, CGRectGetWidth(lblFrame), CGRectGetHeight(lblFrame))];
        [contentView addSubview:label];

        var size = MIN(maxX - MARGIN_SIZE * 2, maxY - CGRectGetHeight(lblFrame) - MARGIN_SIZE * 3);
        var x = (maxX - MARGIN_SIZE * 2 - size) / 2.0;
        var y = (maxY - CGRectGetHeight(lblFrame) - MARGIN_SIZE * 3 - size) / 2.0;
        var image = [[CPImage alloc] initWithContentsOfFile:_artwork["image_url"] size:CGSizeMake(size, size)];
        var imageView = [[CPImageView alloc] initWithFrame:CGRectMake(MARGIN_SIZE + x, MARGIN_SIZE + y, size, size)];
        [imageView setImage:image];
        [contentView addSubview:imageView];

        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(close)
                   name:CPWindowWillCloseNotification
                 object:_window];
    }

    return self;
}

- (CPTextField)labelWithTitle:(CPString)aTitle
{
    var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];

    [label setStringValue:aTitle];
    [label setTextColor:[CPColor whiteColor]];
    [label setFont:[CPFont boldSystemFontOfSize:13.0]];
    [label setAlignment:CPJustifiedTextAlignment];
    [label setLineBreakMode:CPLineBreakByWordWrapping];

    [label sizeToFit];

    return label;
}

- (void)runModal
{
    [CPApp runModalForWindow:_window];
}

- (void)close
{
    [CPApp abortModal];
}

- (void)mouseDown:(CPEvent)anEvent
{
    [_window close];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
    var bounds = [aLayer bounds];
    var fillColor = [CPColor colorWithWhite:0.0 alpha:0.7];

    CGContextSetFillColor(aContext, fillColor);
    CGContextFillRoundedRectangleInRect(aContext, bounds, 20, YES, YES, YES, YES);
}

@end
