/*
 * Author: Martín Conte Mac Donell <Reflejo@gmail.com>
 * Design: Federico Abad <abadfederico@gmail.com?
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

#import "CustomWindow.h"

@implementation CustomWindow

/**
 * Set toolBar window using given color combinations for gradient. 
 * Since "WindowToolBar" uses custom buttons, we need to hide the standard 
 * window buttons (maximize/minimize/close).
 */
-(void)setBarWithInitColor:(NSColor *)initColor endColor:(NSColor *)endColor
{
    NSView *themeFrame = [[self contentView] superview];
    NSRect cFrame = [themeFrame frame];
    NSRect avFrame = [titleView frame];
    NSRect newFrame = NSMakeRect((cFrame.size.width / 2) - (avFrame.size.width / 2),
                                 cFrame.size.height - avFrame.size.height,
                                 avFrame.size.width, avFrame.size.height);
    
    [titleView setGradient:initColor endColor:endColor];
    [titleView setFrame:newFrame];
    [themeFrame addSubview:titleView];
    
    [self setBackgroundColor:kMainWindowGradientInit];

    // Hide default window buttons and remove title
    [[self standardWindowButton:NSWindowCloseButton] setHidden:YES];
    [[self standardWindowButton:NSWindowMiniaturizeButton]setHidden:YES];
    [[self standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [self setTitle:@""];
}

-(void)setToolbarHidden:(BOOL)hide
{
    [titleView setHidden:hide];
}

@end
