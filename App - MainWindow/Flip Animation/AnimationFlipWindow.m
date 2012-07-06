#import "AnimationFlipWindow.h"


@interface AnimationFlipWindow (PrivateMethods)

NSRect RectToScreen(NSRect aRect, NSView *aView);
NSRect RectFromScreen(NSRect aRect, NSView *aView);
NSRect RectFromViewToView(NSRect aRect, NSView *fromView, NSView *toView);

@end

#pragma mark -

@implementation AnimationFlipWindow

@synthesize flipForward = _flipForward;

- (id) init 
{
    
    if ( self = [super init] )
    { 
        _flipForward = YES; 
    }
    
    return self;
}

- (void) flip:(NSWindow *)activeWindow 
       toBack:(NSWindow *)targetWindow
{
    
    CGFloat duration = 1.0f * (activeWindow.currentEvent.modifierFlags & NSShiftKeyMask ? 10.0 : 1.0);
    CGFloat zDistance = 1500.0f;
    
    NSView *activeView = [activeWindow.contentView superview];
    NSView *targetView = [targetWindow.contentView superview];
    
    // Create an animation window
    CGFloat maxWidth  = MAX(NSWidth(activeWindow.frame), NSWidth(targetWindow.frame)) + 500;
    CGFloat maxHeight = MAX(NSHeight(activeWindow.frame), NSHeight(targetWindow.frame)) + 500;
    
    CGRect animationFrame = CGRectMake(NSMidX(activeWindow.frame) - (maxWidth / 2), 
                                       NSMidY(activeWindow.frame) - (maxHeight / 2), 
                                       maxWidth, 
                                       maxHeight);
    
    mAnimationWindow = [NSWindow initForAnimation:NSRectFromCGRect(animationFrame)];
    
    // Add a touch of perspective
    CATransform3D transform = CATransform3DIdentity; 
    transform.m34 = -1.0 / zDistance;
    [mAnimationWindow.contentView layer].sublayerTransform = transform;
    
    // Relocate target window near active window
    CGRect targetFrame = CGRectMake(NSMidX(activeWindow.frame) - (NSWidth(targetWindow.frame) / 2 ), 
                                    NSMaxY(activeWindow.frame) - NSHeight(targetWindow.frame),
                                    NSWidth(targetWindow.frame),
                                    NSHeight(targetWindow.frame));
    
    [targetWindow setFrame:NSRectFromCGRect(targetFrame) display:NO];
    
    mTargetWindow = targetWindow;
    mFromWindow = activeWindow;
    
    // New Active/Target Layers
    [CATransaction begin];
    CALayer *activeWindowLayer = [activeView layerFromWindow];
    CALayer *targetWindowLayer = [targetView layerFromWindow];
    [CATransaction commit];
    
    activeWindowLayer.frame = NSRectToCGRect(RectFromViewToView(activeView.frame, activeView, [mAnimationWindow contentView]));
    targetWindowLayer.frame = NSRectToCGRect(RectFromViewToView(targetView.frame, targetView, [mAnimationWindow contentView]));
    
    [CATransaction begin];
    [[mAnimationWindow.contentView layer] addSublayer:activeWindowLayer];
    [CATransaction commit];
    
    [mAnimationWindow orderFront:nil];  
    
    [CATransaction begin];
    [[mAnimationWindow.contentView layer] addSublayer:targetWindowLayer];
    [CATransaction commit];
    
    // Animate our new layers
    [CATransaction begin];
    CAAnimation *activeAnim = [CAAnimation animationWithDuration:(duration * 0.5) flip:YES forward:_flipForward];
    CAAnimation *targetAnim = [CAAnimation animationWithDuration:(duration * 0.5) flip:NO  forward:_flipForward];
    [CATransaction commit];
    
    targetAnim.delegate = self;
    [activeWindow orderOut:nil];
    
    [CATransaction begin];
    [activeWindowLayer addAnimation:activeAnim forKey:@"flip"];
    [targetWindowLayer addAnimation:targetAnim forKey:@"flip"];
    [CATransaction commit];
}

- (void) animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
    
    if (flag) 
    {
        [mTargetWindow makeKeyAndOrderFront:nil];
        [mAnimationWindow orderOut:nil];
        [mFromWindow close];

        mFromWindow = nil;
        mTargetWindow = nil;
        mAnimationWindow = nil;
    }
}

#pragma mark PrivateMethods:

NSRect RectToScreen(NSRect aRect, NSView *aView) 
{
    aRect = [aView convertRect:aRect toView:nil];
    aRect.origin = [aView.window convertBaseToScreen:aRect.origin];
    return aRect;
}

NSRect RectFromScreen(NSRect aRect, NSView *aView) 
{
    aRect.origin = [aView.window convertScreenToBase:aRect.origin];
    aRect = [aView convertRect:aRect fromView:nil];
    return aRect;
}

NSRect RectFromViewToView(NSRect aRect, NSView *fromView, NSView *toView)
{
    
    aRect = RectToScreen(aRect, fromView);
    aRect = RectFromScreen(aRect, toView);
    
    return aRect;
}

@end

#pragma mark -
#pragma mark CategoryMethods:

@implementation CAAnimation (AnimationFlipWindow)

+ (CAAnimation *) animationWithDuration:(CGFloat)time flip:(BOOL)bFlip forward:(BOOL)forwardFlip
{
    
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    
    CGFloat startValue, endValue;
    
    if ( forwardFlip ) 
    {
        startValue = bFlip ? 0.0f : -M_PI;
        endValue = bFlip ? M_PI : 0.0f;
    } 
    else 
    {
        startValue = bFlip ? 0.0f : M_PI;
        endValue = bFlip ? -M_PI : 0.0f;
    }
    
    flipAnimation.fromValue = [NSNumber numberWithDouble:startValue];
    flipAnimation.toValue = [NSNumber numberWithDouble:endValue];
    
    CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    shrinkAnimation.toValue = [NSNumber numberWithFloat:1.3f];
    shrinkAnimation.duration = time * 0.5;
    shrinkAnimation.autoreverses = YES;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, shrinkAnimation, nil];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = time;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

@end

#pragma mark -

@implementation NSWindow (AnimationFlipWindow)

+ (NSWindow *) initForAnimation:(NSRect)aFrame 
{
    
    NSWindow *window =  [[NSWindow alloc] initWithContentRect:aFrame 
                                                    styleMask:NSBorderlessWindowMask 
                                                      backing:NSBackingStoreBuffered 
                                                        defer:NO];
    [window setOpaque:NO];
    [window setHasShadow:NO];
    [window setBackgroundColor:[NSColor clearColor]];
    [window.contentView setWantsLayer:YES];
    
    return window;
}

@end

#pragma mark -

@implementation NSView (AnimationFlipWindow)

- (CALayer *) layerFromWindow 
{
    
    NSBitmapImageRep *image = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:image];
    
    CALayer *layer = [CALayer layer];
    layer.contents = (id)image.CGImage;
    layer.doubleSided = NO;
    
    // Shadow settings based upon Mac OS X 10.6
    [layer setShadowOpacity:0.5f];
    [layer setShadowOffset:CGSizeMake(0,-10)];
    [layer setShadowRadius:15.0f];
    
    
    return layer;
}

@end