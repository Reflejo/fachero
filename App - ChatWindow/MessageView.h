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
#import "RoundedAvatar.h"

@interface MessageView : NSView {
	BubbleTextView *bubble;
	RoundedAvatar *avatarView;
}

-(id)initWithFrame:(NSRect)frame message:(NSString *)message avatar:(NSImage *)avatar 
			 style:(BubbleStyles)style;

@end
