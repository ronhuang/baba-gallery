@import <AppKit/CPButton.j>

var LABEL_HEIGHT = 26.0;
var OFFSET_HEIGHT = 3.0;

@implementation ThicknessSelector : CPView
{
    CPArray _buttons;
    id _target;
    SEL _action;
    CPTextField _label;
}

- (id)initWithFrame:(CGRect)aFrame thicknesses:(CPArray)anArray
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _buttons = [CPArray array];

        var count = [anArray count];
        var w = CGRectGetWidth(aFrame);
        var h = (CGRectGetHeight(aFrame) - OFFSET_HEIGHT - LABEL_HEIGHT) / count;

        // Add thickness buttons.
        var tg = [ThicknessGroup new];
        for (var i = 0; i < count; i++)
        {
            var btn = [[ThicknessButton alloc] initWithFrame:CGRectMake(0, h * i, w, h) thicknessGroup:tg];
            [btn setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
            [btn setThickness:anArray[i]];
            [self addSubview:btn];

            [_buttons insertObject:btn atIndex:[_buttons count]];
        }

        if (_buttons[0])
        {
            // Default set the first button selected.
            [_buttons[0] setObjectValue:1];
        }

        // Add Label.
        _label = [[CPTextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(aFrame) - LABEL_HEIGHT, w, LABEL_HEIGHT)];
        [_label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_label setAlignment:CPCenterTextAlignment];
        [_label setTextColor:[CPColor colorWithCalibratedWhite:79.0 / 255.0 alpha:1.0]];
        [self addSubview:_label];
    }

    return self;
}

- (void)setTitle:(CPString)aTitle
{
    [_label setStringValue:aTitle];
}

- (CPString)title
{
    return [_label stringValue];
}

- (void)setAction:(SEL)anAction
{
    _action = anAction;
    for (var i = [_buttons count]; i >= 0; i--)
    {
        [_buttons[i] setAction:anAction];
    }
}

- (SEL)action
{
    return _action;
}

- (void)setTarget:(id)aTarget
{
    _target = aTarget;
    for (var i = [_buttons count]; i >= 0; i--)
    {
        [_buttons[i] setTarget:aTarget];
    }
}

- (id)target
{
    return _target;
}

@end

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
