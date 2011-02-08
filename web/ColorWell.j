@import <AppKit/CPColorWell.j>

@implementation ColorWell : CPColorWell
{
    CPString _title;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        var bounds = [self bounds];

        [self setBordered:NO];
        [self drawWellInside:CGRectInset([self bounds], 3.0, 3.0)];
    }

    return self;
}

/* Override to reserve property for label. */
- (void)setBordered:(BOOL)bordered
{
    if (_bordered == bordered)
        return;

    _bordered = bordered;

    [self drawWellInside:CGRectInset([self bounds], 3.0, 3.0)];
}

/* Override to reserve property for label. */
- (void)setColor:(CPColor)aColor
{
    if (_color == aColor)
        return;

    _color = aColor;

    [self drawWellInside:CGRectInset([self bounds], 3.0, 3.0)];
}

- (void)setTitle:(CPString)aTitle
{
}

- (CPString)title
{
    return _title;
}

@end
