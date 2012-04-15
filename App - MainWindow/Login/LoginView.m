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

#import "LoginView.h"
#import "CustomWindow.h"

@implementation LoginView

- (void)awakeFromNib
{
    NSDictionary *colorDict = [NSDictionary dictionaryWithObject:NSColorFromRGB(0xb9b9b9)
                                                          forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *asUserName, *asPassword;
    asUserName = [[NSAttributedString alloc] initWithString:[[username cell] placeholderString]
                                                 attributes:colorDict];
    asPassword = [[NSAttributedString alloc] initWithString:[[password cell] placeholderString]
                                                 attributes:colorDict];

    [[username cell] setPlaceholderAttributedString:asUserName];
    [[password cell] setPlaceholderAttributedString:asPassword];
    
    CustomWindow *window = (CustomWindow *)[self window];
    [window setToolbarHidden:YES];
//    [window setContentSize:NSMakeSize([window frame].size.width, kLoginWindowHeight)];
}

- (void)drawRect:(NSRect)dirtyRect 
{
    NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:kMainWindowGradientInit
                                                          endingColor:kMainWindowGradientEnd];
    [aGradient drawInRect:[self bounds] angle:270];
}

@end
