@import <AppKit/CPView.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPBox.j>
@import "DetailDialog.j"
@import "RLOfflineLocalStorage.j"

var MARGIN_WIDTH = 15.0;
var MARGIN_HEIGHT = 15.0;
var VOTE_HEIGHT = 24.0;

@implementation ArtworkView : CPView
{
    CPView _bgView;
    CPBox _boxView;

    CPImageView _imageView;
    CPTextField _voteTextView;
    CPButton _voteButtonView;

    id _artwork;

    CPURLConnection _voteConn;
    CPURLConnection _viewConn;
}

- (void)setRepresentedObject:(id)anObject
{
    _artwork = anObject;

    var bounds = [self bounds];

    if (!_bgView)
    {
        _bgView = [[CPView alloc] initWithFrame:bounds];
    }

    if (!_imageView)
    {
        var w = CGRectGetWidth(bounds);
        var h = CGRectGetHeight(bounds);
        var size = MIN(w - MARGIN_WIDTH * 2, h - MARGIN_HEIGHT * 2 - MARGIN_HEIGHT - VOTE_HEIGHT);
        var x = (w - MARGIN_WIDTH * 2 - size) / 2.0;
        var y = (h - MARGIN_HEIGHT * 2 - MARGIN_HEIGHT - VOTE_HEIGHT - size) / 2.0;
        _imageView = [[CPImageView alloc] initWithFrame:CGRectMake(MARGIN_WIDTH + x, MARGIN_HEIGHT + y, size, size)];
        [_imageView setImageScaling:CPScaleProportionally];
        [_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_bgView addSubview:_imageView];
    }
    [_imageView setImage:[[CPImage alloc] initWithContentsOfFile:_artwork["thumbnail_url"]]];

    if (!_voteButtonView)
    {
        var y = CGRectGetHeight(bounds) - MARGIN_HEIGHT - VOTE_HEIGHT;
        _voteButtonView = [[CPButton alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, y, CGRectGetWidth(bounds), VOTE_HEIGHT)];
        [_voteButtonView setFont:[CPFont systemFontOfSize:16.0]];
        [_voteButtonView setTarget:self];
        [_voteButtonView setAction:@selector(vote)];
        [_bgView addSubview:_voteButtonView];
    }
    [_voteButtonView setTitle:@"Vote"];
    [_voteButtonView sizeToFit];

    if (!_voteTextView)
    {
        var x = CGRectGetMidX([_voteButtonView bounds]) + CGRectGetWidth([_voteButtonView bounds]);
        var y = CGRectGetHeight(bounds) - MARGIN_HEIGHT - VOTE_HEIGHT;
        _voteTextView = [[CPTextField alloc] initWithFrame:CGRectMake(x, y, CGRectGetWidth(bounds), VOTE_HEIGHT)];
        [_voteTextView setFont:[CPFont systemFontOfSize:16.0]];
        [_bgView addSubview:_voteTextView];
    }
    var votes = _artwork["vote_count"];
    [_voteTextView setStringValue:[self _formatVotes:votes]];

    if (!_boxView)
    {
        _boxView = [CPBox boxEnclosingView:_bgView];
        [_boxView setBorderType:CPLineBorder];
        [_boxView setFillColor:[CPColor colorWithWhite:0.3 alpha:0.2]];
        [_boxView setBorderColor:[CPColor grayColor]];
        [_boxView setBorderWidth:3];
        [_boxView setCornerRadius:20];
        [_boxView setContentViewMargins:10];
        [_boxView setAutoresizingMask:CPViewMaxXMargin | CPViewMinXMargin];
        [self addSubview:_boxView];
    }
}

- (void)vote
{
    if (!_artwork || _voteConn)
        return;

    [_voteButtonView setEnabled:NO];

    var req = [CPURLRequest requestWithURL:_artwork["url"]];
    [req setHTTPMethod:@"PUT"];
    _voteConn = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)voteToLocalStorage
{
    if (!_artwork)
        return;

    var votes = _artwork["vote_count"] + 1;
    _artwork["vote_count"] = votes;
    [self saveArtworkToLocalStorage];

    [_voteTextView setStringValue:[self _formatVotes:votes]];
    [_voteButtonView setEnabled:YES];
}

- (void)saveArtworkToLocalStorage
{
    if (!_artwork)
        return;

    var storage = [RLOfflineLocalStorage sharedOfflineLocalStorage],
        value = nil,
        count = nil,
        artwork_id = _artwork["id"],
        index = nil,
        value = nil,
        key = nil;

    value = [storage getValueForKey:@"artworks.count"];
    count = value && parseInt(value) || 0;

    for (var i = 0; i < count; i++)
    {
        value = [storage getValueForKey:@"artworks[" + i + "].id"];
        index = value && parseInt(value);
        if (index && index == artwork_id)
            break;
    }

    for (var k in _artwork)
    {
        key = @"artworks[" + index + "]." + k;
        [storage removeValueForKey:key];
        [storage setValue:@"" + _artwork["key"] forKey:key];
    }
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    if (_voteConn == connection)
    {
        if (200 != [response statusCode])
        {
            [_voteConn cancel];
            _voteConn = nil;

            // FIXME: Not neccessary correct to fallback to local storage!
            [self voteToLocalStorage];
        }
    }
    else if (_viewConn == connection)
    {
        if (200 != [response statusCode])
        {
            [_viewConn cancel];
            _viewConn = nil;

            // FIXME: Not neccessary correct to fallback to local storage!
            [self viewToLocalStorage];
        }
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (_voteConn == connection)
    {
        var jsObject = [data objectFromJSON];
        _artwork = jsObject["content"][0];

        var votes = _artwork["vote_count"];
        [_voteTextView setStringValue:[self _formatVotes:votes]];
        [_voteButtonView setEnabled:YES];

        _voteConn = nil;
    }
    else if (_viewConn == connection)
    {
        var jsObject = [data objectFromJSON];
        _artwork = jsObject["content"][0];

        var frame = CGRectInset([[self window] frame], 30.0, 30.0);
        var dlg = [[DetailDialog alloc] initWithFrame:frame artwork:_artwork];
        [dlg runModal];

        _viewConn = nil;
    }
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    // TODO: show failed message.
    if (_voteConn == connection)
    {
        _voteConn = nil;

        // FIXME: Not neccessary correct to fallback to local storage!
        [self voteToLocalStorage];
    }
    else if (_viewConn == connection)
    {
        _viewConn = nil;

        // FIXME: Not neccessary correct to fallback to local storage!
        [self viewToLocalStorage];
    }
}

- (CPString)_formatVotes:(int)votes
{
    var voteStr = "";
    if (votes <= 1)
        voteStr = [CPString stringWithFormat:@"%d person liked this", votes];
    else
        voteStr = [CPString stringWithFormat:@"%d people liked this", votes];
    return voteStr;
}

- (void)view
{
    if (!_artwork || _viewConn)
        return;

    // Retrieve latest information
    var req = [CPURLRequest requestWithURL:_artwork["url"]];
    [req setHTTPMethod:@"GET"];
    _viewConn = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)viewToLocalStorage
{
    if (!_artwork)
        return;

    var views = _artwork["view_count"] + 1;
    _artwork["view_count"] = views;
    [self saveArtworkToLocalStorage];

    var frame = CGRectInset([[self window] frame], 30.0, 30.0);
    var dlg = [[DetailDialog alloc] initWithFrame:frame artwork:_artwork];
    [dlg runModal];
}

- (void)mouseDown:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];
    if ([_imageView hitTest:point])
        [self view];
    else
        [super mouseDown:anEvent];
}

@end
