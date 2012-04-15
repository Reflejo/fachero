//
//  RoundedAvatar.m
//  XMPPStream
//
//  Created by Usuario Vacio on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RoundedAvatar.h"

#define STROKE_COLOR    ([NSColor blackColor])
#define STROKE_WIDTH    (4.0)

@implementation RoundedAvatar

@synthesize picture;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        picture = [NSImage imageNamed:@"avatarPlaceholder"];
    }
    
    return self;
}

-(void)setAvatar:(NSImage *)avatar
{
    [self setPicture:avatar];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{   
    NSBezierPath* roundRectPath = [NSBezierPath bezierPathWithRoundedRect:[self bounds] 
                                                                  xRadius:20.0 yRadius:20.0]; 
    [roundRectPath addClip];

    [picture drawInRect:[self bounds]
               fromRect:NSMakeRect(0.0f, 0.0f, picture.size.width, picture.size.height)
              operation:NSCompositeSourceAtop
               fraction:1.0f];
}


-(void)setOnline
{
    if (statusIndicator)
    {
        [statusIndicator setHidden:NO];
        [statusIndicator setImage:[NSImage imageNamed:@"onlineIndicator"]];
    }
}

-(void)setOffline
{
    [statusIndicator setHidden:YES];
//    if (statusIndicator)
//        [statusIndicator setImage:[NSImage imageNamed:@"offlineIndicator"]];
}

@end
