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
