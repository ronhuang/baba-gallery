@import <AppKit/CPView.j>
@import "Canvas.j"

@implementation CanvasView : CPView
{
    CALayer _backgroundLayer;
    CPImage _image;

    Canvas _drawingLayer;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _backgroundLayer = [CALayer layer];

        [self setWantsLayer:YES];
        [self setLayer:_backgroundLayer];

        [_backgroundLayer setDelegate:self];

        [_backgroundLayer setNeedsDisplay];
    }

    return self;
}

- (void)setImage:(CPImage)anImage
{
    if (_image == anImage)
        return;

    _image = anImage;

    [_backgroundLayer setNeedsDisplay];
}

- (void)imageDidLoad:(CPImage)anImage
{
    [_backgroundLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
    var bounds = [aLayer bounds];
    var size = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    var ib = CGRectMake((CGRectGetWidth(bounds) - size) / 2.0, (CGRectGetHeight(bounds) - size) / 2.0, size, size);

    if ([_image loadStatus] != CPImageLoadStatusCompleted)
        [_image setDelegate:self];
    else
        CGContextDrawImage(aContext, ib, _image);
}

@end
