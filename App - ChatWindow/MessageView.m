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

#import "MessageView.h"

#define kMessageAvatarSize	40.0

@implementation MessageView

-(id)initWithFrame:(NSRect)frame message:(NSString *)message avatar:(NSImage *)avatar 
			 style:(BubbleStyles)style
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		NSRect newFrame = frame;
		NSRect avatarFrame = NSMakeRect(0, 0, kMessageAvatarSize, kMessageAvatarSize);
		
		newFrame.size.width -= kMessageAvatarSize;

		if (style == kBubbleTo)
			newFrame.origin.x += kMessageAvatarSize;
		else
			avatarFrame.origin.x += newFrame.size.width;

        bubble = [[BubbleTextView alloc] initWithFrame:newFrame style:kBubbleFrom];
		[bubble setString:message];

		// Set avatar photo to the left if is an stranger or to right if it is
		// the logged user.
		avatarView = [[RoundedAvatar alloc] initWithFrame:avatarFrame];
		if (avatar)
			[avatarView setAvatar:avatar];
		
		[self addSubview:avatarView];
		[self addSubview:bubble];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
