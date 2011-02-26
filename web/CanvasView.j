@import <AppKit/CPView.j>
@import "ImageLayer.j"
@import "CPMutableArray+Queue.j"
@import "ColorWell.j"
@import "ThicknessSelector.j"

CanvasViewCurrentIndexChangedNotification = @"CanvasViewCurrentIndexChangedNotification";

TOOL_PENCIL = 0;
TOOL_ERASER = 1;
TOOL_PICKER = 2;

@implementation CanvasView : CPView
{
    ImageLayer _rootLayer;
    CALayer _drawingLayer;

    CPMutableArray _pixels;
    int _previousIndex;
    int _currentIndex;

    var _attribute;

    CPColor _color @accessors(property=color);
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
        _previousIndex = nil;

        // Attribute
        _attribute = {color:ColorWellDefaultColor, thickness:ThicknessSelectorDefaultThickness, tool:TOOL_PENCIL};

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
        tool = nil,
        i = 0,
        wasBreak = true;
    count = MIN(count, _currentIndex);

    CGContextBeginPath(aContext);
    CGContextSetStrokeColor(aContext, ColorWellDefaultColor);
    CGContextSetLineWidth(aContext, ThicknessSelectorDefaultThickness);

    do
    {
        pixel = [_pixels objectAtIndex:i];
        point = pixel.point;

        if (wasBreak)
        {
            CGContextStrokePath(aContext);

            tool = pixel.attribute.tool;

            CGContextBeginPath(aContext);
            CGContextSetStrokeColor(aContext, pixel.attribute.color);
            CGContextSetLineWidth(aContext, pixel.attribute.thickness);

            switch(tool)
            {
            case TOOL_PENCIL:
                CGContextSetBlendMode(aContext, 0);
                break;
            case TOOL_ERASER:
                CGContextSetBlendMode(aContext, 23);
                break;
            default:
                CPLog.warning(@"Invalid tool: %@", tool);
                break;
            }

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
    if (_attribute.tool == TOOL_PENCIL || _attribute.tool == TOOL_ERASER)
        _previousIndex = _currentIndex;
}

- (void)mouseDragged:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    if (_attribute.tool == TOOL_PENCIL || _attribute.tool == TOOL_ERASER)
    {
        if (_previousIndex == _currentIndex && _previousIndex < [_pixels count])
        {
            // destory the redo stack if any.
            var range = CPMakeRange(_previousIndex, [_pixels count] - _previousIndex);
            [_pixels removeObjectsInRange:range];
        }

        [_pixels push:{point:point, attribute:_attribute}];
        _currentIndex++;
        [_drawingLayer setNeedsDisplay];
    }
}

- (void)mouseUp:(CPEvent)anEvent
{
    var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];

    if (_attribute.tool == TOOL_PENCIL || _attribute.tool == TOOL_ERASER)
    {
        [_pixels push:{point:point, attribute:_attribute, break:YES}];
        _currentIndex++;
        [_drawingLayer setNeedsDisplay];

        [self setCurrentIndex:{current:_currentIndex, previous:_previousIndex}];
    }
    else if (_attribute.tool == TOOL_PICKER)
    {
        var color = [self colorAt:point];

        _attribute = [self cloneAttribute];
        _attribute.color = color;

        [self setColor:color]; // Will notify color well.
    }
}

- (void)setCurrentIndex:(id)indexes
{
    [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(setCurrentIndex:) object:{current:indexes.previous, previous:indexes.current}];

    [[CPNotificationCenter defaultCenter]
        postNotificationName:CanvasViewCurrentIndexChangedNotification
                      object:self];

    _currentIndex = indexes.current;
    [_drawingLayer setNeedsDisplay];
}

- (void)colorWellDidChangeColor:(CPNotification)aNotification
{
    var colorWell = [aNotification object];

    _attribute = [self cloneAttribute];
    _attribute.color = [colorWell color];
}

- (void)thicknessSelectorDidChangeThickness:(CPNotification)aNotification
{
    var selector = [aNotification object];

    _attribute = [self cloneAttribute];
    _attribute.thickness = [selector thickness];
}

- (void)setTool:(CPString)aTool
{
    if (@"pencil" == aTool)
    {
        _attribute = [self cloneAttribute];
        _attribute.tool = TOOL_PENCIL;
    }
    else if (@"eraser" == aTool)
    {
        _attribute = [self cloneAttribute];
        _attribute.tool = TOOL_ERASER;
    }
    else if (@"picker" == aTool)
    {
        _attribute = [self cloneAttribute];
        _attribute.tool = TOOL_PICKER;
    }
    else
        CPLog.warning(@"Unknown tool: %@", aTool);
}

- (void)observeValueForKeyPath:(CPString)aKeyPath
                      ofObject:(id)anObject
                        change:(CPDictionary)aChange
                       context:(id)aContext
{
    if (@"tool" == aKeyPath)
        [self setTool:[aChange objectForKey:CPKeyValueChangeNewKey]];
}

- (id)cloneAttribute
{
    var tmp = {};

    for (var key in _attribute)
        tmp[key] = _attribute[key];

    return tmp;
}

@end
