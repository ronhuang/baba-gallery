@import <AppKit/CPButton.j>

@implementation ThicknessButton : CPButton
{
    ThicknessGroup _thicknessGroup;
    int _thickness;
    BOOL _highlighted @accessors(property=highlighted);
    CGGradient _gradient;
}

// Designated Initializer
- (id)initWithFrame:(CGRect)aFrame thicknessGroup:(ThicknessGroup)aThicknessGroup
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        [self setThicknessGroup:aThicknessGroup];

        [self setHighlightsBy:CPContentsCellMask];
        [self setShowsStateBy:CPContentsCellMask];

        [self setBordered:NO];

        /*
        _gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(),
                                               [[CPColor colorWithHexString:@"e3f3fc"], [CPColor colorWithHexString:@"87b4cd"]],
                                               [0, 1]);
        */
        var components = [170.0 / 255.0, 211.0 / 255.0, 233.0 / 255.0, 1.0, 135.0 / 255.0, 180.0 / 255.0, 205.0 / 255.0, 1.0];
        _gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), components, [0.0, 1.0], 2);
    }

    return self;
}

- (id)initWithFrame:(CGRect)aFrame
{
    return [self initWithFrame:aFrame thicknessGroup:[ThicknessGroup new]];
}

- (CPInteger)nextState
{
    return CPOnState;
}

- (void)setThicknessGroup:(ThicknessGroup)aThicknessGroup
{
    if (_thicknessGroup === aThicknessGroup)
        return;

    [_thicknessGroup _removeThickness:self];
    _thicknessGroup = aThicknessGroup;
    [_thicknessGroup _addThickness:self];
}

- (ThicknessGroup)thicknessGroup
{
    return _thicknessGroup;
}

- (void)setObjectValue:(id)aValue
{
    [super setObjectValue:aValue];

    if ([self state] === CPOnState)
    {
        [_thicknessGroup _setSelectedThickness:self];
        //[self setBackgroundColor:[CPColor colorWithHexString:@"a4cde5"]];
        [self setHighlighted:YES];
    }
    else
    {
        [self setBackgroundColor:[CPColor clearColor]];
        [self setHighlighted:NO];
    }
}

- (void)drawRect:(CPRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort];

    // Draw gradient highlight.
    if ([self highlighted])
    {
        CGContextAddRect(context, aRect);
        CGContextDrawLinearGradient(context, _gradient, CGPointMake(0.0, 0.0), CGPointMake(0.0, CGRectGetHeight(aRect)), 0);
    }

    // Draw thickness.
    var y = (CGRectGetHeight(aRect) - _thickness) / 2.0;
	var rect = CPRectMake(0.0, y, CGRectGetWidth(aRect), _thickness);
    var color = [CPColor blackColor];

    CGContextSetFillColor(context, color);
    CGContextFillRect(context, rect);
}

- (void)setThickness:(int)aThickness
{
    if (_thickness === aThickness)
        return;

    _thickness = aThickness;

    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}

- (int)thickness
{
    return _thickness;
}

@end

@implementation ThicknessGroup : CPObject
{
    CPSet _buttonSet;
    ThicknessButton _selectedButton;

    id _target @accessors(property=target);
    SEL _action @accessors(property=action);
}

- (id)init
{
    self = [super init];

    if (self)
    {
        _buttonSet = [CPSet set];
        _selectedButton = nil;
    }

    return self;
}

- (void)_addThickness:(ThicknessButton)aButton
{
    [_buttonSet addObject:aButton];

    if ([aButton state] === CPOnState)
        [self _setSelectedThickness:aButton];
}

- (void)_removeThickness:(ThicknessButton)aButton
{
    if (_selectedButton === aButton)
        _selectedButton = nil;

    [_buttonSet removeObject:aButton];
}

- (void)_setSelectedThickness:(ThicknessButton)aButton
{
    if (_selectedButton === aButton)
        return;

    [_selectedButton setState:CPOffState];
    _selectedButton = aButton;

    [CPApp sendAction:_action to:_target from:self];
}

- (ThicknessButton)selectedThicknessButton
{
    return _selectedButton;
}

- (CPArray)thicknessButtons
{
    return [_buttonSet allObjects];
}

@end