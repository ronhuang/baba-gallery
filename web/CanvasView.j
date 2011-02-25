@import <AppKit/CPView.j>
@import "ImageLayer.j"
@import "CPMutableArray+Queue.j"

@implementation CanvasView : CPView
{
    ImageLayer _rootLayer;
    CALayer _drawingLayer;

    CPMutableArray _drawPoints;
    CPMutableArray _allPoints;
    int _currentIndex;
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

        // Drawing
        _drawPoints = [];
        _allPoints = [];
        _currentIndex = 0;
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


    // FIXME: use correct color
    CGContextSetStrokeColor(aContext, [CPColor redColor]);


    CGContextBeginPath(aContext);

    var point = nil;
    if ([_allPoints count] > 0)
    {
        point = [_allPoints objectAtIndex:0];
        CGContextMoveToPoint(aContext, point.x, point.y);
    }

    for (i = 0; i < [_allPoints count]; i++)
    {
        point = [_allPoints objectAtIndex:i];
        CGContextAddLineToPoint(aContext, point.x, point.y);
    }


    /*
    var point = [_drawPoints pop];
    if (point)
        CGContextMoveToPoint(aContext, point.x, point.y);

    while (point)
    {
        CGContextAddLineToPoint(aContext, point.x, point.y);
        CGContextStrokeRect(aContext, CGRectMake(point.x, point.y, 1.0, 1.0));

        point = [_drawPoints pop];
    }
    */

    CGContextStrokePath(aContext);


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

- (void)mouseDown:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    [_drawPoints push:point];
    [_allPoints push:point];

    [_drawingLayer setNeedsDisplay];
}

- (void)mouseUp:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    [_drawPoints push:point];
    [_allPoints push:point];

    [_drawingLayer setNeedsDisplay];
}

@end
