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
