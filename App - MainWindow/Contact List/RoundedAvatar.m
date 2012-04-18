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


#import "RoundedAvatar.h"

#define STROKE_COLOR    ([NSColor whiteColor])
#define STROKE_WIDTH    (4.0)

@implementation RoundedAvatar

@synthesize picture, strokeColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self defaultAvatar];
        strokeColor = STROKE_COLOR;
    }
    
    return self;
}

-(void)defaultAvatar
{
    self.picture = [NSImage imageNamed:@"avatarPlaceholder"];
}

-(void)setAvatar:(NSImage *)avatar
{
    [self setPicture:avatar];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{   
    NSRect rectangle = NSInsetRect([self bounds], STROKE_WIDTH / 2.0, STROKE_WIDTH / 2.0);
    NSBezierPath *path = [NSBezierPath bezierPath];

    [path appendBezierPathWithOvalInRect:rectangle];
    [path setLineWidth:STROKE_WIDTH];

    [strokeColor setStroke];
    [path stroke];
    [path addClip];

    [picture drawInRect:[self bounds]
               fromRect:NSMakeRect(0.0f, 0.0f, picture.size.width, picture.size.height)
              operation:NSCompositeSourceAtop
               fraction:1.0f];
}

@end
