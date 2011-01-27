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
}

- (void)setRepresentedObject:(id)anObject
{
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
    [_imageView setImage:[[CPImage alloc] initWithContentsOfFile:anObject["image_url"]]];

    if (!_nameTextView)
    {
        var y = CGRectGetHeight(bounds) - MARGIN_HEIGHT - VOTE_HEIGHT - NAME_HEIGHT;
        _nameTextView = [[CPTextField alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, y, CGRectGetWidth(bounds), NAME_HEIGHT)];
        [_nameTextView setFont:[CPFont systemFontOfSize:16.0]];
        [_bgView addSubview:_nameTextView];
    }
    [_nameTextView setStringValue:[CPString stringWithFormat:@"Artist: %s", anObject["name"]]];
    [_nameTextView sizeToFit];

    if (!_voteButtonView)
    {
        var y = CGRectGetHeight(bounds) - MARGIN_HEIGHT - VOTE_HEIGHT;
        _voteButtonView = [[CPButton alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, y, CGRectGetWidth(bounds), VOTE_HEIGHT)];
        [_voteButtonView setFont:[CPFont systemFontOfSize:16.0]];
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
    var votes = anObject["vote_count"];
    var voteStr = "";
    if (votes <= 1)
        voteStr = [CPString stringWithFormat:@"%d person liked this", votes];
    else
        voteStr = [CPString stringWithFormat:@"%d people liked this", votes];
    [_voteTextView setStringValue:voteStr];

    if (!_boxView)
    {
        _boxView = [CPBox boxEnclosingView:_bgView];
        [_boxView setBorderType:CPLineBorder];
        [_boxView setFillColor:[CPColor whiteColor]];
        [_boxView setBorderColor:[CPColor colorWithHexString:"C5C5C5"]];
        [_boxView setBorderWidth:3];
        [_boxView setCornerRadius:20];
        [_boxView setContentViewMargins:10];
        [_boxView setAutoresizingMask:CPViewMaxXMargin | CPViewMinXMargin];
        [self addSubview:_boxView];
    }
}

@end
