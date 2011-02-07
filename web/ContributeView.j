@import <AppKit/CPView.j>
@import <AppKit/CPBox.j>
@import <AppKit/CPButton.j>

var SEP_WIDTH = 10.0;
var ICON_WIDTH = 64.0;
var ICON_HEIGHT = 64.0;
var ICON_DESCRIPTION_HEIGHT = 24.0;
var TOOL_HEIGHT = 110.0;
var TOOL_HEIGHT_2 = TOOL_HEIGHT / 2.0;
var TOOL_MARGIN = 15.0;

@implementation ContributeView : CPView
{
    CPView _toolView;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        var bounds = [self bounds];

        _toolView = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(bounds), TOOL_HEIGHT)];
        [_toolView setBackgroundColor:[CPColor lightGrayColor]];
        [_toolView setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin];
        [self addSubview:_toolView];

        /* Action buttons. */
        [self _addButtonWithTitle:@"New" imagePath:@"document-new.png" action:@selector(new) atIndex:0];
        [self _addButtonWithTitle:@"Submit" imagePath:@"document-save-3.png" action:@selector(submit) atIndex:1];
        [self _addButtonWithTitle:@"Undo" imagePath:@"edit-undo.png" action:@selector(undo) atIndex:2];
        [self _addButtonWithTitle:@"Redo" imagePath:@"edit-redo.png" action:@selector(redo) atIndex:3];
        [self _addButtonWithTitle:@"Zoom out" imagePath:@"zoom-out-3.png" action:@selector(zoomOut) atIndex:4];
        [self _addButtonWithTitle:@"Zoom in" imagePath:@"zoom-in-3.png" action:@selector(zoomIn) atIndex:5];
        [self _addButtonWithTitle:@"Pencil" imagePath:@"draw-brush.png" action:@selector(pencil) atIndex:6];
        [self _addButtonWithTitle:@"Eraser" imagePath:@"draw-eraser-2.png" action:@selector(eraser) atIndex:7];
        var btn = [self _addButtonWithTitle:@"Picker" imagePath:@"color-picker.png" action:@selector(picker) atIndex:8];

        /* Brush thickness. */
        var x = CGRectGetMaxX([btn bounds]);
        var h = (TOOL_HEIGHT - ICON_DESCRIPTION_HEIGHT) / 5;
        var btn = [[CPButton alloc] initWithFrame:CGRectMake(x, TOOL_MARGIN, ICON_WIDTH, h)];
    }

    return self;
}

- (CPButton)_addButtonWithTitle:(CPString)aTitle imagePath:(CPString)aImagePath action:(SEL)anAction atIndex:(int)anIndex
{
    var mainBundle = [CPBundle mainBundle];
    var x = anIndex * (ICON_WIDTH + SEP_WIDTH);

    var btn = [[CPButton alloc] initWithFrame:CGRectMake(x, TOOL_MARGIN, ICON_WIDTH, ICON_HEIGHT + ICON_DESCRIPTION_HEIGHT)];
    [btn setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
    [btn setImagePosition:CPImageAbove];
    [btn setBordered:NO];

    [btn setTitle:aTitle];

    var img = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:aImagePath] size:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)];
    [btn setImage:img];
    //var altImg = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:anAltImagePath]];
    //[btn setAlternateImage:altImg];

    [btn setTarget:self];
    [btn setAction:anAction];

    [_toolView addSubview:btn];

    return btn;
}

- (void)new
{
    CPLog.trace(@"new");
}

- (void)submit
{
    CPLog.trace(@"submit");
}

- (void)undo
{
    CPLog.trace(@"undo");
}

- (void)redo
{
    CPLog.trace(@"redo");
}

- (void)zoomOut
{
    CPLog.trace(@"zoom out");
}

- (void)zoomIn
{
    CPLog.trace(@"zoom in");
}

- (void)pencil
{
    CPLog.trace(@"pencil");
}

- (void)eraser
{
    CPLog.trace(@"eraser");
}

- (void)picker
{
    CPLog.trace(@"picker");
}

@end
