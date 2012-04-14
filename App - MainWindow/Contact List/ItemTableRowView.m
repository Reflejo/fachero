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
    NSLog(@"SAIDJAIS");
/*    NSImage *indicator = [NSImage imageNamed:@"selectedIndicator"];
    [indicator drawInRect:dirtyRect 
                 fromRect:dirtyRect//NSMakeRect(0, 0, indicator.size.width, indicator.size.height) 
                operation:NSCompositeSourceOver
                 fraction:1.0];*/
}

- (void)drawRect:(NSRect)dirtyRect
{
    float xOffset = NSMinX([self convertRect:[self frame] toView:nil]);
    float yOffset = NSMaxY([self convertRect:[self frame] toView:nil]);

//    CGContextSetPatternPhase((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort],
//                             CGSizeMake(0, 0));
//    [[NSGraphicsContext currentContext] saveGraphicsState];
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)];

    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"contactRowBackground"]] set];
    NSRectFill([self bounds]);
//    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
//    [super drawRect:dirtyRect];

  //  NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);*/
}


@end
