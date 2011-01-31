@import <AppKit/CPView.j>
@import <AppKit/CPBox.j>
@import <AppKit/CPButton.j>

var TOOL_HEIGHT = 100.0;
var TOOL_HEIGHT_2 = TOOL_HEIGHT / 2.0;
var SEP_WIDTH = 2.0;

@implementation ContributeView : CPView
{
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        var bounds = [self bounds];
        var mainBundle = [CPBundle mainBundle];

        var submitButton = [[CPButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, TOOL_HEIGHT)];
        //var submitButton = [[CPButton alloc] initWithFrame:CGRectMakeZero()];
        [submitButton setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
        var img = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"document-save-3.png"]];
        [submitButton setImage:img];
        [submitButton setImagePosition:CPImageOnly];
        [self addSubview:submitButton];
    }

    return self;
}

@end
