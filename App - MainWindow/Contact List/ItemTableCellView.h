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

#import <AppKit/AppKit.h>
#import "RoundedAvatar.h"
#import "XMPPUser.h"

@interface ItemTableCellView : NSTableCellView {
    IBOutlet NSTextField *name;
    
@public
    IBOutlet RoundedAvatar *avatar;
    IBOutlet NSImageView *statusIndicator;
    id <XMPPUser> user;
    BOOL isSelected;
}

- (void)setIsSelected:(BOOL)isSelected;

-(void)setUser:(id <XMPPUser>) user;
-(void)setOnline;
-(void)setOffline;

@end
