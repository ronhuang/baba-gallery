@import <AppKit/CPView.j>
@import "ImageLayer.j"

@implementation CanvasView : CPView
{
    ImageLayer _rootLayer;
    CALayer _drawingLayer;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _rootLayer = [ImageLayer layer];

        [self setWantsLayer:YES];
        [self setLayer:_rootLayer];

        _drawingLayer = [CALayer layer];
        [_drawingLayer setDelegate:self];
        [_drawingLayer setAnchorPoint:CGPointMakeZero()];

        [_rootLayer addSublayer:_drawingLayer];

        [_drawingLayer setNeedsDisplay];

        [_rootLayer setNeedsDisplay];
    }

    return self;
}

- (void)setImage:(CPImage)anImage
{
    [_rootLayer setImage:anImage];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
    CGContextSaveGState(aContext);
    CGContextTranslateCTM(aContext, CGRectGetMinX([aLayer bounds]), 0.0);


    /*
    CGContextSetStrokeColor(aContext, [CPColor redColor]);
    CGContextStrokeRect(aContext, CGRectMake(150.0, 100.0, 50.0, 100.0));
    */


    CGContextRestoreGState(aContext);
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

    // Set bounds for sublayer as well.
    [_drawingLayer setBounds:CGRectMake(x, 0.0, size, size)];
}

@end
