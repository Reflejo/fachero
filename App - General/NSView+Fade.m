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

#import "NSView+Fade.h"

/**
 * A category on NSView that allows fade in/out on setHidden:
 */

@implementation NSView(Fade)

/**
 * Hides or unhides an NSView, making it fade in or our of existance.
 * @param hidden YES to hide, NO to show
 * @param fade if NO, just setHidden normally.
 */
- (IBAction)setHidden:(BOOL)hidden withFade:(BOOL)fade 
{
    if (!fade) 
    {
        // The easy way out.  Nothing to do here...
        [self setHidden:hidden];
    } 
    else 
    {
        if (!hidden) 
        {
            // If we're unhiding, make sure we queue an unhide before the animation
            [self setHidden:NO];
        }
        
        NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [animDict setObject:self forKey:NSViewAnimationTargetKey];
        [animDict setObject:(hidden ? NSViewAnimationFadeOutEffect: NSViewAnimationFadeInEffect) 
                     forKey:NSViewAnimationEffectKey];
        NSViewAnimation *anim = [[NSViewAnimation alloc] 
                                 initWithViewAnimations:[NSArray arrayWithObject:animDict]];
        [anim setDuration:0.5];
        [anim startAnimation];
    }
}

@end
