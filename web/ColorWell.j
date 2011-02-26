@import <AppKit/CPColorWell.j>

ColorWellColorDidChangeNotification = @"ColorWellColorDidChangeNotification";
ColorWellDefaultColor = [CPColor yellowColor];

var LABEL_HEIGHT = 26.0;
var OFFSET_HEIGHT = 3.0;

@implementation ColorWell : CPColorWell
{
    CPTextField _label;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        var bounds = [self bounds];
        var w = CGRectGetWidth(aFrame);

        [self setBordered:NO];
        [self setColor:ColorWellDefaultColor];

        // Add Label.
        _label = [[CPTextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(aFrame) - LABEL_HEIGHT, w, LABEL_HEIGHT)];
        [_label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_label setAlignment:CPCenterTextAlignment];
        [_label setTextColor:[CPColor colorWithCalibratedWhite:79.0 / 255.0 alpha:1.0]];
        [self addSubview:_label];
    }

    return self;
}

/* Override to add border. */
- (void)drawWellInside:(CGRect)aRect
{
    if (!aRect)
    {
        aRect = CGRectMakeCopy([self bounds]);
        aRect.size.height -= OFFSET_HEIGHT + LABEL_HEIGHT;
    }

    if (!_wellView)
    {
        _wellView = [[CPBox alloc] initWithFrame:aRect];
        [_wellView setBorderType:CPLineBorder];
        [_wellView setBorderColor:[CPColor colorWithHexString:@"C5C5C5"]];
        [_wellView setBorderWidth:3];
        [_wellView setCornerRadius:10];
        [_wellView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [self addSubview:_wellView];
    }
    else
        [_wellView setFrame:aRect];

    [_wellView setFillColor:_color];
}

/* Override to reserve property for label. */
- (void)setBordered:(BOOL)bordered
{
    if (_bordered == bordered)
        return;

    _bordered = bordered;

    [self drawWellInside:nil];
}

/* Override to reserve property for label. */
- (void)setColor:(CPColor)aColor
{
    if (_color == aColor)
        return;

    _color = aColor;

    [[CPNotificationCenter defaultCenter]
        postNotificationName:ColorWellColorDidChangeNotification
                      object:self];

    [self drawWellInside:nil];
}

- (void)setTitle:(CPString)aTitle
{
    [_label setStringValue:aTitle];
}

- (CPString)title
{
    return [_label stringValue];
}

@end
