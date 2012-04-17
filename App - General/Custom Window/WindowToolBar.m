/*
 * Author: Martín Conte Mac Donell <Reflejo@gmail.com>
 * Design: Federico Abad <abadfederico@gmail.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this work except in compliance with the License.
 * You may obtain a copy of the License in the LICENSE file, or at:
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "WindowToolBar.h"


#if IN_COMPILING_MOUNTAIN
const CGFloat OSCornerClipRadius = 6.0;
#else
const CGFloat OSCornerClipRadius = 4.0;
#endif

#define kFontSize   16.0

@implementation WindowToolBar


- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];     
    [notificationCenter removeObserver:self];
}

/**
 * Emulate close behaivor. Remember that close button is our internal one.
 */
- (void)closeWindow 
{
    NSWindow *window = [self window];
    id delegate = [window delegate];
    
    // Check if window want to stay up.
    if ([delegate respondsToSelector:@selector(windowShouldClose:)] && 
        ![delegate windowShouldClose:window])
        return;
    
    [window close];
}


/**
 * Paint toolbar using given color combinations for gradient.
 */
-(void)setGradient:(NSColor *)color1 endColor:(NSColor *)color2
{
    initColor = color1;
    endColor = color2;    
    
    [self setNeedsDisplay:YES];
}

/**
 * Setup window information and add needed buttons
 */
- (id)initWithFrame:(NSRect)frame 
{
    if ((self = [super initWithFrame:frame]) != nil)
    {
        double margin = (frame.size.height / 2) - (kFontSize / 2);
        buttonsHover = NO;
        
        closeButton = [[NSImageView alloc] initWithFrame:NSMakeRect(margin / 2, margin, 16.0, 16.0)];
        [closeButton setImage:[NSImage imageNamed:@"close-active-color"]];
        [self addSubview:closeButton];
        
        minimizeButton = [[NSImageView alloc] initWithFrame:NSMakeRect((margin / 2) + 22.0, margin, 16.0, 16.0)];
        [minimizeButton setImage:[NSImage imageNamed:@"minimize-active-color"]];
        [self addSubview:minimizeButton];
        
        zoomButton = [[NSImageView alloc] initWithFrame:NSMakeRect((margin / 2) + (22.0 * 2), margin, 16.0, 16.0)];
        [zoomButton setImage:[NSImage imageNamed:@"zoom-active-color"]];
        [self addSubview:zoomButton];
        
        titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, -margin, frame.size.width, frame.size.height)];
        [titleLabel setAutoresizingMask:NSViewMinYMargin | NSViewWidthSizable];
        [titleLabel setAlignment:NSCenterTextAlignment];
        [titleLabel setTextColor:[NSColor whiteColor]];
        [[titleLabel cell] setBackgroundStyle:NSBackgroundStyleDark];

        [titleLabel setDrawsBackground:NO];
        [titleLabel setBordered:NO];
        [titleLabel setEditable:NO];
        [self addSubview:titleLabel];
        
        [self addTrackingRect:NSMakeRect(0.0, 0.0, 68.0, 30.0) owner:self userData:nil assumeInside:NO];
        
        titleBackgrounds = [[NSArray alloc] initWithObjects:
                            [NSImage imageNamed:@"titleBackgroundLeft"],
                            [NSImage imageNamed:@"titleBackgroundMiddle"],
                            [NSImage imageNamed:@"titleBackgroundRight"],nil];

    }
    
    return self;
}

/**
 * Refresh button position and color. Buttons will change on focus lose or mouse rollover.
 */
- (void)refreshButtons 
{
    BOOL isKeyWindow = [[self window] isKeyWindow];
    NSString *imageName;

    if (buttonsHover) 
    {
        imageName = @"close-rollover-color";
    } 
    else if ([[self window] isKeyWindow]) 
    {
        imageName = @"close-active-color";
    } 
    else 
    {
        imageName = @"activenokey-color";
    }
    
    [closeButton setImage:[NSImage imageNamed:imageName]];
    
    // Minimize
    if (buttonsHover)
        imageName = @"minimize-rollover-color";
    else if (isKeyWindow)
        imageName = @"minimize-active-color";
    else
        imageName = @"activenokey-color";
    
    [minimizeButton setImage:[NSImage imageNamed:imageName]];
    
    // Zoom
    if (buttonsHover)
        imageName = @"zoom-rollover-color";
    else if (isKeyWindow)
        imageName = @"zoom-active-color";
    else
        imageName = @"activenokey-color";
    
    [zoomButton setImage:[NSImage imageNamed:imageName]];
    
    [self setNeedsDisplay:YES];
}

/**
 * MOUSE EVENTS
 */
- (void)mouseEntered:(NSEvent *)theEvent 
{
    buttonsHover = YES;
    [self refreshButtons];
}

- (void)mouseExited:(NSEvent *)theEvent 
{
    buttonsHover = NO;
    [self refreshButtons];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSWindow *window = [self window];
    if ([window isMovable])
    {
        NSPoint origin = [window frame].origin;
        [window setFrameOrigin:NSMakePoint(origin.x + [theEvent deltaX], origin.y - [theEvent deltaY])];
    }
}

- (void)mouseUp:(NSEvent *)theEvent 
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (NSPointInRect(location, [closeButton frame]))
        [self closeWindow];

    else if (NSPointInRect(location, [minimizeButton frame]))
        [[self window] miniaturize:nil];

    else if (NSPointInRect(location, [zoomButton frame]))
        [[self window] performZoom:nil];
}


/**
 * This method is used to observe focus changes
 */
- (void)viewWillMoveToWindow:(NSWindow *)newWindow 
{
    NSString *title = ([newWindow title]) ? [newWindow title]: @"";
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];     

    [notificationCenter addObserver:self selector:@selector(windowKeyChanged:) 
                               name:NSWindowDidBecomeKeyNotification object:NULL];
    [notificationCenter addObserver:self selector:@selector(windowKeyChanged:) 
                               name:NSWindowDidResignKeyNotification object:NULL];
    
    [titleLabel setStringValue:title];
    [super viewWillMoveToWindow:newWindow];
}

/**
 * This function round the borders to keep the standard aspects of 
 * OSX windows.
 */
- (NSBezierPath *)clippingPathWithRect:(NSRect)aRect cornerRadius:(CGFloat)radius
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect rect = NSInsetRect(aRect, radius, radius);
    NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect));

    // Create a rounded rectangle path, omitting the bottom left/right corners
    [path appendBezierPathWithPoints:&cornerPoint count:1];
    cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
    [path appendBezierPathWithPoints:&cornerPoint count:1];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect))
                                     radius:radius startAngle:0.0 endAngle:90.0];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) 
                                     radius:radius startAngle:90.0 endAngle:180.0];
    [path closePath];
    return path;
}

/**
 * Paint toolbar using saved colors.
 */
- (void)drawRect:(NSRect)dirtyRect 
{
    NSDrawThreePartImage([self bounds], [titleBackgrounds objectAtIndex:0], 
                         [titleBackgrounds objectAtIndex:1], 
                         [titleBackgrounds objectAtIndex:2], NO,
                         NSCompositeSourceOver, 1, NO);

}

/**
 * Refresh button on focus change
 */
- (void)windowKeyChanged:(id)object 
{
    [self refreshButtons];
}

@end
