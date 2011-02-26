@import <AppKit/CPView.j>
@import "ImageLayer.j"
@import "CPMutableArray+Queue.j"
@import "ColorWell.j"
@import "ThicknessSelector.j"

@implementation CanvasView : CPView
{
    ImageLayer _rootLayer;
    CALayer _drawingLayer;

    CPMutableArray _pixels;
    int _currentIndex;

    CPDictionary _attribute;
    CPColor _color;
    int _thickness;

    CPString _tool;
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
        _pixels = [];
        _currentIndex = 0;

        // Attribute
        _color = ColorWellDefaultColor;
        _thickness = ThicknessSelectorDefaultThickness;
        _attribute = {color:_color, thickness:_thickness};

        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(colorWellDidChangeColor:)
                   name:ColorWellColorDidChangeNotification
                 object:nil];
        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(thicknessSelectorDidChangeThickness:)
                   name:ThicknessSelectorThicknessDidChangeNotification
                 object:nil];

        // Default tool
        _tool = @"pencil";
    }

    return self;
}

- (void)setImage:(CPImage)anImage
{
    [_rootLayer setImage:anImage];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
    var count = [_pixels count];

    if (count <= 0)
        return;

    CGContextSaveGState(aContext);
    CGContextTranslateCTM(aContext, CGRectGetMinX([aLayer bounds]), 0.0);
    CGContextSetLineCap(aContext, 1);
    CGContextSetLineJoin(aContext, 1);


    var pixel = nil,
        point = nil,
        color = nil,
        thickness = nil,
        i = 0,
        wasBreak = true;

    CGContextBeginPath(aContext);
    CGContextSetStrokeColor(aContext, ColorWellDefaultColor);
    CGContextSetLineWidth(aContext, ThicknessSelectorDefaultThickness);

    do
    {
        pixel = [_pixels objectAtIndex:i];
        point = pixel.point;
        color = pixel.attribute.color;
        thickness = pixel.attribute.thickness;

        if (wasBreak)
        {
            CGContextStrokePath(aContext);

            CGContextBeginPath(aContext);
            CGContextSetStrokeColor(aContext, color);
            CGContextSetLineWidth(aContext, thickness);
            CGContextMoveToPoint(aContext, point.x, point.y);
        }

        CGContextAddLineToPoint(aContext, point.x, point.y);

        wasBreak = pixel.break;
        i++;
    }
    while (i < count);

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
}

- (void)mouseDragged:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    [_pixels push:{point:point, attribute:_attribute}];

    [_drawingLayer setNeedsDisplay];
}

- (void)mouseUp:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    [_pixels push:{point:point, attribute:_attribute, break:true}];

    [_drawingLayer setNeedsDisplay];
}

- (void)colorWellDidChangeColor:(CPNotification)aNotification
{
    var colorWell = [aNotification object];

    _color = [colorWell color];

    _attribute = {color:_color, thickness:_thickness};
}

- (void)thicknessSelectorDidChangeThickness:(CPNotification)aNotification
{
    var selector = [aNotification object];

    _thickness = [selector thickness];

    _attribute = {color:_color, thickness:_thickness};
}

- (void)setTool:(CPString)aTool
{
    if (_tool == aTool)
        return;

    _tool = aTool;

    if (@"pencil" == _tool)
    {
    }
    else if (@"eraser" == _tool)
    {
    }
    else if (@"picker" == _tool)
    {
    }
    else
        CPLog.warning(@"Unknown tool: %@", _tool);
}

- (CPString)tool
{
    return _tool;
}

- (void)observeValueForKeyPath:(CPString)aKeyPath
                      ofObject:(id)anObject
                        change:(CPDictionary)aChange
                       context:(id)aContext
{
    if (@"tool" == aKeyPath)
        [self setTool:[aChange objectForKey:CPKeyValueChangeNewKey]];
}

@end
