//
//  ItemTableCellView.m
//  Penteskine
//
//  Created by Martin Conte Mac Donell on 10/17/11.
//  Copyright 2011 kodear. All rights reserved.
//

#import "ItemTableCellView.h"

#define kNormalColor        0x404040
#define kHighLightColor     0xffffff


@implementation ItemTableCellView

/**
 * Remove shadow from Cells texts and change color/image if selected
 */
- (void)setStyleToField:(NSTextField *)field
{
    NSMutableAttributedString *attrs = [[field attributedStringValue] mutableCopy];

    NSColor *shadowColor = (isSelected) ? [NSColor blackColor]: [NSColor whiteColor];
    shadowColor = [shadowColor colorWithAlphaComponent:0.5];

    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:shadowColor];
    [shadow setShadowBlurRadius:0];
    [shadow setShadowOffset:NSMakeSize(1, -1)];
    
    [attrs addAttribute:NSShadowAttributeName value:shadow
                  range:NSMakeRange(0, [attrs length])];
    

    NSColor *color = NSColorFromRGB((isSelected) ? kHighLightColor: kNormalColor);
    [attrs addAttribute:NSForegroundColorAttributeName value:color
                  range:NSMakeRange(0, [attrs length])];
    
    [field setAttributedStringValue:attrs];
}

- (void)setUser:(id <XMPPUser>)xmppuser
{
    user = xmppuser;
    [name setStringValue:[user nickname]];
}

- (void)viewWillDraw 
{
    [super viewWillDraw];
    [self setStyleToField:name];
}

/**
 * Set isSelected flag but also redraw cell to see correct colors
 */
- (void)setIsSelected:(BOOL)_isSelected
{
    isSelected = _isSelected;
    [self setNeedsDisplay:YES];
}

@end
