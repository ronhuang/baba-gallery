@implementation CPMutableArray (Queue)

- (id)pop
{
    var obj = nil;

    if ([self count])
    {
        obj = [self objectAtIndex:0];
        [self removeObjectAtIndex:0];
    }

    return obj;
}

- (void)push:(id)anObject
{
    [self addObject:anObject];
}

@end
