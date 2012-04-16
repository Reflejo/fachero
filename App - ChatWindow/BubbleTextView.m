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

#import "BubbleTextView.h"
#import "NSImage+Section.h"

#define kBalloonHeight              32.0
#define kBalloonWidth               43.0
#define kBalloonTail                17.0
#define kBalloonEnd                 17.0
#define kBalloonBottom              14.0
#define kBalloonTop                 10.0

@implementation BubbleTextView

@synthesize style;

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        fromParts = [self balloonTileArray:[NSImage imageNamed:@"fromBubble"]];
        toParts = [self balloonTileArray:[NSImage imageNamed:@"toBubble"]];
        style = kBubbleFrom;    
        [self setDrawsBackground:NO];
        [self setEditable:NO];
    }
    return self;
    
}

-(void)awakeFromNib
{
    [self setTextContainerInset:NSMakeSize(kBalloonTop, kBalloonTop)];
}

///////////////////////////////////////////////////////////
// Image manipulation
///////////////////////////////////////////////////////////
#pragma mark Image manipulation
/**
 * Splits a balloon image into its 9 part tile components, 
 * to be used in NSDrawNinePartImage.
 */
- (NSArray *)balloonTileArray:(NSImage *)balloon
{
    NSRect r = NSMakeRect(0, kBalloonHeight - kBalloonTop, kBalloonTail, kBalloonTop);
    NSImage *tl = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.y = kBalloonBottom; 
    r.size.height = kBalloonHeight - kBalloonTop - kBalloonBottom;
    NSImage *le = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.x = 0; r.origin.y = 0; r.size.height = kBalloonBottom;
    NSImage *bl = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.x = kBalloonTail; r.size.width = 1;
    NSImage *be = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.y = kBalloonBottom; 
    r.size.height = kBalloonHeight - kBalloonTop - kBalloonBottom;
    NSImage *cf = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.y = kBalloonHeight - kBalloonTop;
    r.size.height = kBalloonTop;
    NSImage *te = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.x = kBalloonWidth - kBalloonEnd;
    r.size.width = kBalloonEnd;
    NSImage *tr = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.y = kBalloonBottom;
    r.size.height = kBalloonHeight - kBalloonTop - kBalloonBottom;
    NSImage *re = [NSImage imageWithRect:r ofImage:balloon];
    
    r.origin.y = 0;
    r.size.height = kBalloonBottom;
    NSImage *br = [NSImage imageWithRect:r ofImage:balloon];
    
    return [NSArray arrayWithObjects:tl,te,tr,le,cf,re,bl,be,br,nil];
}

- (void)drawViewBackgroundInRect:(NSRect)rect 
{
    NSArray *bubbleParts = (style == kBubbleFrom) ? fromParts: toParts;

    // Draw the background first, before the bubbles.
    [super drawViewBackgroundInRect:rect];
    NSDrawNinePartImage([self bounds],
                        [bubbleParts objectAtIndex:0],
                        [bubbleParts objectAtIndex:1],
                        [bubbleParts objectAtIndex:2],
                        [bubbleParts objectAtIndex:3],
                        [bubbleParts objectAtIndex:4],
                        [bubbleParts objectAtIndex:5],
                        [bubbleParts objectAtIndex:6],
                        [bubbleParts objectAtIndex:7],
                        [bubbleParts objectAtIndex:8], 
                        NSCompositeSourceOver, 1.0, YES);
}

@end
