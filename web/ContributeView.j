@import <AppKit/CPView.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPAlert.j>
@import "ThicknessSelector.j"
@import "ColorWell.j"
@import "CanvasView.j"
@import "CPView+Export.j"
@import "SubmittingDialog.j"

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
    ThicknessSelector _thicknessSelector;
    CanvasView _canvasView;

    CPAlert _confirmAlert;
    CPPanel _submittingAlert;
    CPAlert _resultAlert;
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
        var x = [self _addButtonWithTitle:@"Picker" imagePath:@"color-picker.png" action:@selector(picker) atIndex:8];

        /* Brush thickness. */
        var frame = CGRectMake(x, TOOL_MARGIN, ICON_WIDTH, TOOL_HEIGHT - TOOL_MARGIN);
        var thicknesses = [1, 2, 3, 4, 5];
        _thicknessSelector = [[ThicknessSelector alloc] initWithFrame:frame thicknesses:thicknesses];
        [_thicknessSelector setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
        [_thicknessSelector setTitle:@"Size"];
        [_thicknessSelector setTarget:self];
        [_thicknessSelector setAction:@selector(thickness)];
        [_toolView addSubview:_thicknessSelector];

        /* Current color. */
        var frame = CGRectMake(x + ICON_WIDTH + SEP_WIDTH, TOOL_MARGIN, ICON_WIDTH, TOOL_HEIGHT - TOOL_MARGIN);
        var well = [[ColorWell alloc] initWithFrame:frame];
        [well setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
        [well setTitle:@"Color"];
        [_toolView addSubview:well];

        /* Canvas */
        var mainBundle = [CPBundle mainBundle];
        var path = [mainBundle pathForResource:@"original.jpg"];
        var image = [[CPImage alloc] initWithContentsOfFile:path];

        _canvasView = [[CanvasView alloc] initWithFrame:CGRectMake(0.0, TOOL_HEIGHT, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - TOOL_HEIGHT)];
        [_canvasView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_canvasView setImage:image];
        [self addSubview:_canvasView];
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

    return x + ICON_WIDTH + SEP_WIDTH;
}

- (void)new
{
    CPLog.trace(@"new");
}

- (void)submit
{
    _confirmAlert = [CPAlert alertWithMessageText:@"Ready to submit your work?" defaultButton:@"Submit" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Click Submit to submit your work to the server. Click Cancel if you want to continue the restoration."];
    [_confirmAlert setDelegate:self];
    [_confirmAlert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if (theAlert == _confirmAlert)
    {
        [self handleConfirmAlert:returnCode];
    }
    else if (theAlert == _resultAlert)
    {
        [self handleResultAlert:returnCode];
    }
}

- (void)handleConfirmAlert:(int)returnCode
{
    _confirmAlert = nil;

    if (returnCode != 0)
    {
        // Yes - 0
        // No - 1
        // User clicked No. Do nothing.
        return;
    }

    // Show submitting alert.
    _submittingAlert = [[SubmittingDialog alloc] init];
    [_submittingAlert runModal];

    // Submit to server.
    var img = [_canvasView mergedImage];

    var content = [[CPString alloc] initWithFormat:@"image=%@", [img.src urlencode]];
    var contentLength = [[CPString alloc] initWithFormat:@"%d", [content length]];

    var req = [[CPURLRequest alloc] initWithURL:@"/artworks"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:content];
    [req setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [req setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    var conn = [CPURLConnection connectionWithRequest:req delegate:self];
	[conn start];
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (_submittingAlert)
    {
        [_submittingAlert close];
        _submittingAlert = nil;
    }

    _resultAlert = [CPAlert alertWithMessageText:@"Thank you for your contribution." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You can go to the Gallery to view your work."];
    [_resultAlert setDelegate:self];
    [_resultAlert runModal];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    if (_submittingAlert)
    {
        [_submittingAlert close];
        _submittingAlert = nil;
    }

    var alert = [CPAlert alertWithError:@""];
    [alert runModal];
}

- (void)handleResultAlert:(int)returnCode
{
    _resultAlert = nil;

    // TODO: Reset the ContributeView.
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

- (void)thickness
{
    CPLog.trace(@"thickness");
}

- (void)color
{
    CPLog.trace(@"color");
}

@end
