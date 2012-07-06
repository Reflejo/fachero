

#import <QuartzCore/QuartzCore.h>

@interface AnimationFlipWindow : NSObject {
    
    BOOL _flipForward;
    
    NSWindow *mAnimationWindow;
    NSWindow *mTargetWindow;
    NSWindow *mFromWindow;
}

// Direction of flip animation (property)
@property (readwrite, getter=isFlipForward) BOOL flipForward;

- (void) flip:(NSWindow *)activeWindow 
       toBack:(NSWindow *)targetWindow;
@end

#pragma mark -
#pragma mark CategoryMethods:

@interface CAAnimation (AnimationFlipWindow)
+ (CAAnimation *) animationWithDuration:(CGFloat)time 
                                   flip:(BOOL)bFlip // Flip for each side
                                forward:(BOOL)forwardFlip; // Direction of flip
@end

@interface NSWindow (AnimationFlipWindow)
+ (NSWindow *) initForAnimation:(NSRect)aFrame;
@end

@interface NSView (AnimationFlipWindow)
- (CALayer *) layerFromWindow;
@end