//
//  ItemTableRowView.m
//  Penteskine
//
//  Created by Martin Conte Mac Donell on 10/18/11.
//  Copyright 2011 kodear. All rights reserved.
//

#import "ItemTableRowView.h"

@implementation ItemTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    float xOffset = NSMinX([self convertRect:[self frame] toView:nil]);
    float yOffset = NSMaxY([self convertRect:[self frame] toView:nil]);
    
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)];
    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"selectedIndicator"]] set];
    NSRectFill([self bounds]);
/*
    NSImage *indicator = [NSImage imageNamed:@"selectedIndicator"];
    [indicator drawInRect:dirtyRect 
                 fromRect:dirtyRect//NSMakeRect(0, 0, indicator.size.width, indicator.size.height) 
                operation:NSCompositeSourceOver
                 fraction:1.0];
*/
}

- (void)drawRect:(NSRect)dirtyRect
{
    if ([self isSelected])
        return [super drawRect:dirtyRect];
    
    float xOffset = NSMinX([self convertRect:[self frame] toView:nil]);
    float yOffset = NSMaxY([self convertRect:[self frame] toView:nil]);

    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)];
    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"contactRowBackground"]] set];
    NSRectFill([self bounds]);
}

@end
