@import <AppKit/CPView.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPBox.j>

var MARGIN_WIDTH = 15.0;
var MARGIN_HEIGHT = 15.0;
var NAME_HEIGHT = 24.0;
var VOTE_HEIGHT = 24.0;

@implementation ArtworkView : CPView
{
    CPView _bgView;
    CPBox _boxView;

    CPImageView _imageView;
    CPTextField _nameTextView;
    CPTextField _voteTextView;
    CPButton _voteButtonView;

    id _artwork;
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
        var w = CGRectGetWidth(bounds) - MARGIN_WIDTH * 2;
        var h = CGRectGetHeight(bounds) - MARGIN_HEIGHT * 2 - NAME_HEIGHT - VOTE_HEIGHT;
        _imageView = [[CPImageView alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, MARGIN_HEIGHT, w, h)];
        [_imageView setImageScaling:CPScaleProportionally];
        [_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_bgView addSubview:_imageView];
    }
    [_imageView setImage:[[CPImage alloc] initWithContentsOfFile:_artwork["thumbnail_url"]]];

    if (!_nameTextView)
    {
        var y = CGRectGetHeight(bounds) - MARGIN_HEIGHT - VOTE_HEIGHT - NAME_HEIGHT;
        _nameTextView = [[CPTextField alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, y, CGRectGetWidth(bounds), NAME_HEIGHT)];
        [_nameTextView setFont:[CPFont systemFontOfSize:16.0]];
        [_bgView addSubview:_nameTextView];
    }
    [_nameTextView setStringValue:[CPString stringWithFormat:@"Artist: %s", _artwork["name"]]];
    [_nameTextView sizeToFit];

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
        [_boxView setFillColor:[CPColor whiteColor]];
        [_boxView setBorderColor:[CPColor colorWithHexString:@"C5C5C5"]];
        [_boxView setBorderWidth:3];
        [_boxView setCornerRadius:20];
        [_boxView setContentViewMargins:10];
        [_boxView setAutoresizingMask:CPViewMaxXMargin | CPViewMinXMargin];
        [self addSubview:_boxView];
    }
}

- (void)vote
{
    if (!_artwork)
    {
        return;
    }

    [_voteButtonView setEnabled:NO];

    var req = [CPURLRequest requestWithURL:_artwork["url"]];
    [req setHTTPMethod:@"PUT"];
    connection = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    var jsObject = [data objectFromJSON];
    _artwork = jsObject["content"][0];

    var votes = _artwork["vote_count"];
    [_voteTextView setStringValue:[self _formatVotes:votes]];
    [_voteButtonView setEnabled:YES];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    // TODO: show failed message.

    [_voteButtonView setEnabled:YES];
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

@end
