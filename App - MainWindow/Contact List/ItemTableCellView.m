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

#import "ItemTableCellView.h"

#define kNormalColor        0x000000
#define kHighLightColor     0xffffff


@implementation ItemTableCellView

- (void)awakeFromNib
{
    [self setStyleToField:name];
}

/**
 * Remove shadow from Cells texts and change color/image if selected
 */
- (void)setStyleToField:(NSTextField *)field
{
    NSMutableAttributedString *attrs = [[field attributedStringValue] mutableCopy];

    NSColor *shadowColor = (isSelected) ? [NSColor blackColor]: [NSColor whiteColor];
    shadowColor = [shadowColor colorWithAlphaComponent:0.5];

    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:shadowColor];
    [shadow setShadowBlurRadius:0];
    [shadow setShadowOffset:NSMakeSize(1, -1)];
    
    [attrs addAttribute:NSShadowAttributeName value:shadow
                  range:NSMakeRange(0, [attrs length])];

    NSColor *color = NSColorFromRGB((isSelected) ? kHighLightColor: kNormalColor);
    [attrs addAttribute:NSForegroundColorAttributeName value:color
                  range:NSMakeRange(0, [attrs length])];
    
    [field setAttributedStringValue:attrs];
}

- (void)setUser:(id <XMPPUser>)xmppuser
{
    user = xmppuser;
    [name setStringValue:[user nickname]];
}

/**
 * Set isSelected flag but also redraw cell to see correct colors
 */
- (void)setIsSelected:(BOOL)_isSelected
{
    isSelected = _isSelected;
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
