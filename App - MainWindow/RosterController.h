/*
 * Author: Mart’n Conte Mac Donell <Reflejo@gmail.com>
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

#import "ItemTableCellView.h"
#import "ItemTableRowView.h"
#import "RoundedAvatar.h"


@interface RosterController : NSObject <NSTableViewDelegate> {
	BOOL isOpen;
	BOOL isAuthenticating;

	NSArray *roster;
    
	// Sign-In Sheet
	IBOutlet NSPanel     * signInSheet;
	IBOutlet NSTextField * jidField;
    IBOutlet NSTextField * passwordField;
	IBOutlet NSButton    * rememberPasswordCheckbox;
    IBOutlet NSButton    * signInButton;
	IBOutlet NSTextField * messageField;

	// Roster Window	
	IBOutlet NSWindow    * window;
    IBOutlet NSTableView * rosterTable;
	
	// Profile info
	IBOutlet NSTextField * userName;
	IBOutlet RoundedAvatar * userAvatar;
}

// Sign-In Sheet
- (void)displaySignInSheet;
- (IBAction)signIn:(id)sender;

// Roster Window
- (IBAction)changePresence:(id)sender;
- (IBAction)chat:(id)sender;

@end
