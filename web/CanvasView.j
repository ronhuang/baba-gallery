@import <AppKit/CPView.j>
@import "CanvasLayer.j"

@implementation CanvasView : CPView
{
    CALayer _backgroundLayer;
    CPImage _image;

    CanvasLayer _drawingLayer;
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

    if ([_image loadStatus] != CPImageLoadStatusCompleted)
        [_image setDelegate:self];
    else
        CGContextDrawImage(aContext, bounds, _image);
}

- (void)resizeWithOldSuperviewSize:(CGSize)aSize
{
    var cframe = [self frame];
    var pframe = [[self superview] frame];

    var x = 0.0;
    var y = CGRectGetMinY(cframe);
    var w = CGRectGetWidth(pframe);
    var h = CGRectGetHeight(pframe) - CGRectGetMinY(cframe);
    var size = MIN(w, h);

    if (w > size)
        x = (w - size) / 2.0; // center

    [self setFrame:CGRectMake(x, y, size, size)];
}

@end
