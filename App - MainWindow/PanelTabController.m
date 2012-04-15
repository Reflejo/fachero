//
//  PanelTabController.m
//  Penteskine
//
//  Created by Martin Conte Mac Donell on 10/22/11.
//  Copyright 2011 kodear. All rights reserved.
//

#import "PanelTabController.h"
#import <QuartzCore/QuartzCore.h>
//#import "NSView+Fade.h"

// Convenience function to clear an NSBitmapImageRep's bits to zero.
static void ClearBitmapImageRep(NSBitmapImageRep *bitmap) 
{
    unsigned char *bitmapData = [bitmap bitmapData];
    
    if (bitmapData)
        // A fast alternative to filling with [NSColor clearColor]
        bzero(bitmapData, [bitmap bytesPerRow] * [bitmap pixelsHigh]);
}

@implementation PanelTabController

#pragma mark -
#pragma mark Animation stuff

- (void)awakeFromNib 
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSData *shading = [NSData dataWithContentsOfFile:
                       [bundle pathForResource:@"restrictedshine" ofType:@"tiff"]];
    NSBitmapImageRep *shadingBitmap = [[NSBitmapImageRep alloc] initWithData:shading];
    inputShadingImage = [[CIImage alloc] initWithBitmapImageRep:shadingBitmap];
}

- (void)drawRect:(NSRect)rect 
{
    // First, draw the normal TabView content.  If we're animating, we will have hidden 
    // the TabView's content view, so invoking [super drawRect:rect] will just draw the 
    // tabs, border, and inset background.
    [super drawRect:rect];
    
    // If we're in the middle of animating, composite the animation result atop the base 
    // TabView content.
    if (animation != nil) 
    {
        // Get outputCIImage for the current phase of the animation.  (This doesn't 
        // actually cause the image to be rendered just yet.)
        [transitionFilter setValue:[NSNumber numberWithFloat:[animation currentValue]] 
                            forKey:@"inputTime"];
        CIImage *outputCIImage = [transitionFilter valueForKey:@"outputImage"];
        
        [outputCIImage drawInRect:imageRect
                         fromRect:NSMakeRect(0, imageRect.size.height, imageRect.size.width, -imageRect.size.height) 
                        operation:NSCompositeSourceOver 
                         fraction:1.0];
    }
}

- (void)createTransitionFilterForRect:(NSRect)rect initialCIImage:(CIImage *)initialCIImage
                         finalCIImage:(CIImage *)finalCIImage
{
    /*transitionFilter = [CIFilter filterWithName:@"CIRippleTransition"];
    [transitionFilter setDefaults];
    [transitionFilter setValue:[CIVector vectorWithX:NSMidX(rect)
                                                   Y:NSMidY(rect)]
                        forKey:@"inputCenter"];
    [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x 
                                                   Y:rect.origin.y 
                                                   Z:rect.size.width 
                                                   W:rect.size.height] 
                        forKey:@"inputExtent"];
    
    [transitionFilter setValue:inputShadingImage forKey:@"inputShadingImage"];*/
    transitionFilter = [CIFilter filterWithName:@"CISwipeTransition"];
    [transitionFilter setDefaults];
    
    [transitionFilter setValue:initialCIImage forKey:@"inputImage"];
    [transitionFilter setValue:finalCIImage forKey:@"inputTargetImage"];
}

- (void)selectTabViewItem:(NSTabViewItem *)tabViewItem 
{
    // Make a note of the content view of the NSTabViewItem we're switching from, and the
    // content view of the one we're switching to.
    NSView *initialContentView = [[self selectedTabViewItem] view];
    NSView *finalContentView = [tabViewItem view];
    
    // Compute bounds and frame rectangles big enough to encompass both views.  
    // (We'll use imageRect later, to composite the animation frames into the right 
    // place within the AnimatingTabView.)
    NSRect rect = NSUnionRect([initialContentView bounds], [finalContentView bounds]);
    imageRect = NSUnionRect([initialContentView frame], [finalContentView frame]);
    
    // Render the initialContentView to a bitmap.  When using the 
    // -cacheDisplayInRect:toBitmapImageRep: and -displayRectIgnoringOpacity:inContext: 
    // methods, remember to first initialize the destination to clear if the content to be 
    // drawn won't cover it with full opacity.
    NSBitmapImageRep *initialContentBitmap;
    initialContentBitmap = [initialContentView bitmapImageRepForCachingDisplayInRect:rect];
    ClearBitmapImageRep(initialContentBitmap);
    [initialContentView cacheDisplayInRect:rect toBitmapImageRep:initialContentBitmap];
    
    // Invoke super's implementation of -selectTabViewItem: to switch to the requested 
    // tabViewItem.  The NSTabView will mark itself as needing display, but the window 
    // will not have redrawn yet, so this is our chance to animate the transition!
    [super selectTabViewItem:tabViewItem];
    
    // Render the finalContentView to a bitmap.
    NSBitmapImageRep *finalContentBitmap = [finalContentView bitmapImageRepForCachingDisplayInRect:rect];
    ClearBitmapImageRep(finalContentBitmap);
    [finalContentView cacheDisplayInRect:rect toBitmapImageRep:finalContentBitmap];
    
    // Build a Core Image filter that will morph the initialContentBitmap into the finalContentBitmap.
    CIImage *initialCIImage = [[CIImage alloc] initWithBitmapImageRep:initialContentBitmap];
    CIImage *finalCIImage = [[CIImage alloc] initWithBitmapImageRep:finalContentBitmap];
    [self createTransitionFilterForRect:rect initialCIImage:initialCIImage finalCIImage:finalCIImage];
    
    // Create an instance of TabViewAnimation to drive the transition over time.  Set the
    // AnimatingTabView to be the TabViewAnimation's delegate, so the TabViewAnimation 
    // will know which view to redisplay as the animation progresses.
    animation = [[TabViewAnimation alloc] initWithDuration:3.0
                                            animationCurve:NSAnimationEaseInOut];
    [animation setDelegate:self];
    
    // Hide the TabView's new content view for the duration of the animation.
    [finalContentView setHidden:1];
    
    // Run the animation synchronously.
    [animation startAnimation];
    
    // Clean up after the animation has finished.
    animation = 0;
    transitionFilter = 0;
    [finalContentView setHidden:0];
    [self setNeedsDisplay:YES];
}

@end

#pragma mark -
#pragma mark TabViewAnimation

@implementation TabViewAnimation

// Override NSAnimation's -setCurrentProgress: method, and use it as our point to hook in 
// and advance our Core Image transition effect to the next time slice.
- (void)setCurrentProgress:(NSAnimationProgress)progress 
{
    [super setCurrentProgress:progress];
    [(id)[self delegate] display];
}
@end