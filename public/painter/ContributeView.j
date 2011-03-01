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
var TOOL_MARGIN = 10.0;
var CANVAS_MARGIN = 2.0;

@implementation ContributeView : CPView
{
    CPView _toolView;
    ThicknessSelector _thicknessSelector;
    CanvasView _canvasView;

    CPButton _undoButton;
    CPButton _redoButton;
    CPButton _pencilButton;
    CPButton _eraserButton;
    CPButton _pickerButton;
    CPButton _currentButton;

    CPAlert _resetAlert;
    CPAlert _confirmAlert;
    CPPanel _submittingAlert;
    CPAlert _resultAlert;

    CPString _tool;

    CPString _contentToSubmit;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        /* UI components */
        var bounds = [self bounds];

        _toolView = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(bounds), TOOL_HEIGHT)];
        //[_toolView setBackgroundColor:[CPColor colorWithWhite:0.9 alpha:0.2]];
        var borderLayer = [CALayer layer];
        [borderLayer setDelegate:self];
        [borderLayer setNeedsDisplay];
        [borderLayer setZPosition:-1.0];
        [_toolView setWantsLayer:YES];
        [_toolView setLayer:borderLayer];
        [_toolView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMaxYMargin];
        [self addSubview:_toolView];

        /* Action buttons. */
        [self _addButtonWithTitle:@"New" imagePath:@"document-new.png" altImagePath:@"document-new-alt.png" action:@selector(new) atBase:0];
        [self _addButtonWithTitle:@"Submit" imagePath:@"document-save-3.png" altImagePath:@"document-save-3-alt.png" action:@selector(submit) atBase:1];

        _undoButton = [self _addButtonWithTitle:@"Undo" imagePath:@"edit-undo.png" altImagePath:@"edit-undo-alt.png" action:@selector(undo) atBase:2.25];
        _redoButton = [self _addButtonWithTitle:@"Redo" imagePath:@"edit-redo.png" altImagePath:@"edit-redo-alt.png" action:@selector(redo) atBase:3.25];

        _pencilButton = [self _addButtonWithTitle:@"Pencil" imagePath:@"draw-brush.png" altImagePath:@"draw-brush-alt.png" action:@selector(pencil) atBase:4.5];
        _eraserButton = [self _addButtonWithTitle:@"Eraser" imagePath:@"draw-eraser-2.png" altImagePath:@"draw-eraser-2-alt.png" action:@selector(eraser) atBase:5.5];
        _pickerButton = [self _addButtonWithTitle:@"Picker" imagePath:@"color-picker.png" altImagePath:@"color-picker-alt.png" action:@selector(picker) atBase:6.5];

        /* Brush thickness. */
        var x = CGRectGetMaxX([_pickerButton frame]) + SEP_WIDTH + ICON_WIDTH * 0.25 + SEP_WIDTH;
        var frame = CGRectMake(x, TOOL_MARGIN, ICON_WIDTH, TOOL_HEIGHT - TOOL_MARGIN);
        var thicknesses = [1, 2, 3, 4, 5];
        _thicknessSelector = [[ThicknessSelector alloc] initWithFrame:frame thicknesses:thicknesses];
        [_thicknessSelector setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
        [_thicknessSelector setTitle:@"Size"];
        [_toolView addSubview:_thicknessSelector];

        /* Current color. */
        var x = CGRectGetMaxX([_thicknessSelector frame]) + SEP_WIDTH;
        var frame = CGRectMake(x, TOOL_MARGIN, ICON_WIDTH, TOOL_HEIGHT - TOOL_MARGIN);
        var well = [[ColorWell alloc] initWithFrame:frame];
        [well setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
        [well setTitle:@"Color"];
        [_toolView addSubview:well];

        /* Now that we have all the tool bar items, final adjust the toolbar to make it align center. */
        var w = CGRectGetMaxX([well frame]) + SEP_WIDTH;
        var x = (CGRectGetWidth(bounds) - w) / 2.0;
        [_toolView setFrame:CGRectMake(x, 0.0, w, TOOL_HEIGHT)];

        /* Canvas */
        var mainBundle = [CPBundle mainBundle];
        var path = [mainBundle pathForResource:@"original.jpg"];
        var image = [[CPImage alloc] initWithContentsOfFile:path];

        var size = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds) - TOOL_HEIGHT - CANVAS_MARGIN);
        var x = (CGRectGetWidth(bounds) - size) / 2.0;
        _canvasView = [[CanvasView alloc] initWithFrame:CGRectMake(x, TOOL_HEIGHT + CANVAS_MARGIN, size, size)];
        [_canvasView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_canvasView setImage:image];
        [self addSubview:_canvasView];


        /* Drawing logics */
        [self addObserver:_canvasView forKeyPath:@"tool" options:CPKeyValueObservingOptionNew context:NULL];
        [_canvasView addObserver:well forKeyPath:@"color" options:CPKeyValueObservingOptionNew context:NULL];
        [self setTool:@"pencil"];

        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(updateUndoOrRedoButtons:)
                   name:CPUndoManagerDidUndoChangeNotification
                 object:nil];
        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(updateUndoOrRedoButtons:)
                   name:CPUndoManagerDidRedoChangeNotification
                 object:nil];
        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(updateUndoOrRedoButtons:)
                   name:CanvasViewCurrentIndexChangedNotification
                 object:nil];
        [_undoButton setEnabled:NO];
        [_redoButton setEnabled:NO];
    }

    return self;
}

- (CPButton)_addButtonWithTitle:(CPString)aTitle imagePath:(CPString)aImagePath altImagePath:(CPString)anAltImagePath action:(SEL)anAction atBase:(float)aBase
{
    var mainBundle = [CPBundle mainBundle];
    var x = aBase * (ICON_WIDTH + SEP_WIDTH);

    var btn = [[CPButton alloc] initWithFrame:CGRectMake(x, TOOL_MARGIN, ICON_WIDTH, ICON_HEIGHT + ICON_DESCRIPTION_HEIGHT)];
    [btn setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
    [btn setImagePosition:CPImageAbove];
    [btn setBordered:NO];
    [btn setImageDimsWhenDisabled:YES];

    [btn setTitle:aTitle];

    var img = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:aImagePath] size:CGSizeMake(ICON_WIDTH, ICON_HEIGHT)];
    [btn setImage:img];
    var altImg = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:anAltImagePath]];
    [btn setAlternateImage:altImg];

    [btn setTarget:self];
    [btn setAction:anAction];

    [_toolView addSubview:btn];

    return btn;
}

- (void)setTool:(CPString)aTool
{
    if (_tool == aTool)
        return;

    _tool = aTool;

    var dd = {pencil:_pencilButton, eraser:_eraserButton, picker:_pickerButton};
    var btn = dd[aTool];
    [self highlightButton:btn];
}

- (CPString)tool
{
    return _tool;
}

- (void)highlightButton:(CPButton)aButton
{
    if (_currentButton == aButton)
        return;

    var borderWidth = 2;

    if (_currentButton)
    {
        // Remove box.
        var box = [_currentButton superview];
        var frame = [box frame];
        var enclosingView = [box superview];

        [enclosingView replaceSubview:box with:_currentButton];
        [_currentButton setFrame:CGRectInset(frame, borderWidth / 2, borderWidth / 2)];
    }

    var box = [CPBox boxEnclosingView:aButton];
    [box setBorderType:CPLineBorder];
    [box setCornerRadius:10];
    [box setBorderWidth:borderWidth];
    [box setBorderColor:[CPColor darkGrayColor]];

    _currentButton = aButton;
}

- (void)new
{
    if (![_canvasView dirty])
        return;

    _resetAlert = [CPAlert alertWithMessageText:@"Create new canvas?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Click OK to create a new canvas. Your work will not be submitted to the server. Click Cancel if you want to continue the restoration."];
    [_resetAlert setDelegate:self];
    [_resetAlert runModal];
}

- (void)reset
{
    if (![_canvasView dirty])
        return;

    [_canvasView reset];
    [_undoButton setEnabled:NO];
    [_redoButton setEnabled:NO];
    _contentToSubmit = nil;
}

- (void)submitToLocalStorage
{
    var storage = [RLOfflineLocalStorage sharedOfflineLocalStorage],
        value = nil,
        count = nil,
        key = nil,

    value = [storage getValueForKey:@"artworks.count"];
    count = value && parseInt(value) || 0;

    // Check if invalid
    key = @"artworks[" + count + "].id";
    if ([storage getValueForKey:key])
    {
        // The value should not exist!
        // TODO: do something?
    }

    // Generate ID
    var artwork = {
        name: "",
        email: "",
        created_at: (new Date()).getTime(),
        updated_at: (new Date()).getTime(),
        view_count: 0,
        vote_count: 0,
        image: "",
        thumbnail: "",
        id: [CPString UUID],
        image_url: _contentToSubmit,
        thumbnail_url: _contentToSubmit,
    };

    for (var k in artwork)
    {
        key = @"artworks[" + count + "]." + k;
        [storage setValue:@"" + artwork["key"] forKey:key];
    }

    // Update count.
    count++;
    key = @"artworks.count";
    [storage removeValueForKey:key]; // necessary?
    [storage setValue:@"" + count forKey:key];


    if (_submittingAlert)
    {
        [_submittingAlert close];
        _submittingAlert = nil;
    }

    _resultAlert = [CPAlert alertWithMessageText:@"Thank you for your contribution." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You can go to the Gallery to view your work."];
    [_resultAlert setDelegate:self];
    [_resultAlert runModal];
}

- (void)submit
{
    _confirmAlert = [CPAlert alertWithMessageText:@"Ready to submit your work?" defaultButton:@"Submit" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Click Submit to submit your work to the server. Click Cancel if you want to continue the restoration."];
    [_confirmAlert setDelegate:self];
    [_confirmAlert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if (theAlert == _resetAlert)
    {
        [self handleResetAlert:returnCode];
    }
    else if (theAlert == _confirmAlert)
    {
        [self handleConfirmAlert:returnCode];
    }
    else if (theAlert == _resultAlert)
    {
        [self handleResultAlert:returnCode];
    }
}

- (void)handleResetAlert:(int)returnCode
{
    _resetAlert = nil;

    if (returnCode != 0)
    {
        // Yes - 0
        // No - 1
        // User clicked No. Do nothing.
        return;
    }

    [self reset];
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
    var data = [_canvasView mergedImageInDataUriScheme];
    _contentToSubmit = [[CPString alloc] initWithFormat:@"image=%@", encodeURIComponent(data)];

    var req = [[CPURLRequest alloc] initWithURL:@"/artworks"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:_contentToSubmit];
    [req setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
    if (200 != [response statusCode])
    {
        [connection cancel];

        // FIXME: Not neccessary correct to fallback to local storage!
        [self submitToLocalStorage];
    }
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
    // FIXME: Not neccessary correct to fallback to local storage!
    [self submitToLocalStorage];
}

- (void)handleResultAlert:(int)returnCode
{
    _resultAlert = nil;

    [self reset];
}

- (void)undo
{
    [[[self window] undoManager] undo];
}

- (void)redo
{
    [[[self window] undoManager] redo];
}

- (void)pencil
{
    [self setTool:@"pencil"];
}

- (void)eraser
{
    [self setTool:@"eraser"];
}

- (void)picker
{
    [self setTool:@"picker"];
}

- (void)updateUndoOrRedoButtons:(CPNotification)aNotification
{
    var manager = [[self window] undoManager];

    [_redoButton setEnabled:[manager canRedo]];
    [_undoButton setEnabled:[manager canUndo]];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
    var bounds = [aLayer bounds];
    var fillColor = [CPColor colorWithWhite:0.3 alpha:0.2];
    var borderColor = [CPColor grayColor];

    CGContextSetFillColor(aContext, fillColor);
    CGContextFillRoundedRectangleInRect(aContext, bounds, 20, YES, YES, YES, YES);

    CGContextSetStrokeColor(aContext, borderColor);
    CGContextSetLineWidth(aContext, 2);
    CGContextStrokeRoundedRectangleInRect(aContext, bounds, 20, YES, YES, YES, YES);
}

@end
