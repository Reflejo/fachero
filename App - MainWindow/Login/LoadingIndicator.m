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

#import "LoadingIndicator.h"

#import <QuartzCore/QuartzCore.h>

@implementation LoadingIndicator

#define kImageFrames        3

/**
 * Load indicator animation
 */
- (id)initWithFrame:(NSRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
        NSMutableArray *images = [NSMutableArray array];
        CALayer *droidLayer = [CALayer layer];
        
        CGImageSourceRef source;
        NSImage *image;
        
        for (int i = 0; i <= kImageFrames; i++)
        {
            image = [NSImage imageNamed:[NSString stringWithFormat:@"loadIndicator%d", i]]; 
            source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], 
                                                 NULL);
            [images addObject:(__bridge id)CGImageSourceCreateImageAtIndex(source, 0, NULL)];
            
            CFRelease(source);
        }
        
        [anim setKeyPath:@"contents"];
        [anim setValues:images];
        [anim setCalculationMode:kCAAnimationDiscrete];
        [anim setRepeatCount:HUGE_VAL];
        [anim setDuration:1.0];
        [droidLayer addAnimation:anim forKey:nil];
        [self setLayer:droidLayer];
        [self setWantsLayer:YES];
    }
    
    return self;
}

@end
