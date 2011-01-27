@import <AppKit/CPView.j>
@import <AppKit/CPBox.j>

@implementation ContributeView : CPView
{
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        var bounds = [self bounds];

        var descLabel = [[CPTextField alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(bounds), 50.0)];
        [descLabel setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin];
        [descLabel setStringValue:@"Short description."];
        [descLabel setFont:[CPFont boldSystemFontOfSize:100.0]];
        [descLabel sizeToFit];
        [self addSubview:descLabel];

        var quoteBox = [CPBox boxEnclosingView:descLabel];
        [quoteBox setFillColor:[CPColor colorWithHexString:"FFFFFF"]];
        [quoteBox setBorderType:CPLineBorder];
        [quoteBox setBorderColor:[CPColor colorWithHexString:"C5C5C5"]];
        [quoteBox setBorderWidth:1];
        [quoteBox setCornerRadius:10];
        [quoteBox setContentViewMargins:10];
        [quoteBox setAutoresizingMask:CPViewMaxXMargin|CPViewMinXMargin];
        [quoteBox setFrameOrigin:CGPointMake(([self frame].size.width-[descLabel frame].size.width)/2,10)];
        [self addSubview:quoteBox];
    }

    return self;
}

@end
