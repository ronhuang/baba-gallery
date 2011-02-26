@import <AppKit/CPImage.j>

@implementation ImageLayer : CALayer
{
    CPImage _image;
}

- (void)setImage:(CPImage)anImage
{
    if (_image == anImage)
        return;

    _image = anImage;

    [self setNeedsDisplay];
}

- (void)imageDidLoad:(CPImage)anImage
{
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContext)aContext
{
    var bounds = [self bounds];

    if ([_image loadStatus] != CPImageLoadStatusCompleted)
        [_image setDelegate:self];
    else
        CGContextDrawImage(aContext, bounds, _image);
}

@end
