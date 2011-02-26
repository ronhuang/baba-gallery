@import <AppKit/CPPanel.j>
@import <AppKit/CPWindowController.j>

@implementation SubmittingDialog : CPWindowController
{
    CPWindow _window;
}

- (id)init
{
    _window = [[CPPanel alloc] initWithContentRect:CGRectMake(0, 0, 225, 125) styleMask:CPTitledWindowMask];

    self = [super initWithWindow:_window];

    if (self)
    {
        var contentView = [_window contentView],
            bounds = [contentView bounds],
            centerX = CGRectGetWidth(bounds) / 2,
            maxY = CGRectGetHeight(bounds),
            inset = 15;

        var label = [self labelWithTitle:@"Submitting..."];
        [label setFrameOrigin:CGPointMake(centerX - CGRectGetWidth([label frame]) / 2, inset)];
        [contentView addSubview:label];

        var path = [[CPBundle mainBundle] pathForResource:@"throbber.gif"];
        var image = [[CPImage alloc] initWithContentsOfFile:path size:CGSizeMake(220, 19)];
        var size = [image size];
        var imageView = [[CPImageView alloc] initWithFrame:CGRectMake(centerX - size.width / 2, 70, size.width, size.height)];
        [imageView setImage:image];
        [contentView addSubview:imageView];
    }

    return self;
}

- (CPTextField)labelWithTitle:(CPString)aTitle
{
    var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];

    [label setStringValue:aTitle];
    [label setTextColor:[CPColor blackColor]];
    [label setFont:[CPFont boldSystemFontOfSize:13.0]];
    [label setAlignment:CPJustifiedTextAlignment];
    [label setLineBreakMode:CPLineBreakByWordWrapping];

    [label sizeToFit];

    return label;
}

- (void)runModal
{
    [CPApp runModalForWindow:_window];
}

- (void)close
{
    [CPApp abortModal];
    [_window close];
}

@end
