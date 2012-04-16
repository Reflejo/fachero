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

#import <WebKit/WebKit.h>

@class XMPPStream;
@class XMPPMessage;
@class XMPPJID;

@interface ChatController : NSWindowController
{
    __strong XMPPStream *xmppStream;
    __strong XMPPJID *jid;
    __strong XMPPMessage *firstMessage;
    NSMutableArray *messages;

    IBOutlet id messageField;
//    IBOutlet id messageView;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSTableView *tableView;


    IBOutlet WebView *webView;
}

- (id)initWithStream:(XMPPStream *)xmppStream jid:(XMPPJID *)jid;
- (id)initWithStream:(XMPPStream *)xmppStream jid:(XMPPJID *)jid message:(XMPPMessage *)message;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPJID *jid;

- (IBAction)sendMessage:(id)sender;

@end
