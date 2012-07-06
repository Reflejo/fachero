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

#import "ChatController.h"
#import "WindowManager.h"
#import "XMPPFramework.h"
#import "AppDelegate.h"
#import "StyleManager.h"

@interface ChatController (PrivateAPI)
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ChatController

@synthesize xmppStream;
@synthesize jid;

/**
 * XMPP Roaster storage, We'll find users and avatars here
 */
- (XMPPRosterMemoryStorage *)storage
{
    return [[NSApp delegate] xmppRosterStorage];
}

/**
 * Initialization objects message is there because an user could start chatting
 * to us and his/her window could be closed.
 */
- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid
{
    return [self initWithStream:stream jid:aJid message:nil];
}

- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid message:(XMPPMessage *)message
{
    if ((self = [super initWithWindowNibName:@"ChatWindow"]))
    {
        webViewIsReady = NO;
        xmppStream = stream;
        jid = aJid;
        
        firstMessage = message;
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

        // WARNING: This will raise an awakeFromNib call.
        // Set window title to our contact nickname
        [[self window] setTitle:[[self storage] userForJID:aJid].nickname];
        
        // Window Customization (remove minimize/zoom butons and set window background)
        [[[self window] standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
        [[[self window] standardWindowButton:NSWindowZoomButton] setHidden:YES];
        [[self window] makeFirstResponder:messageField];
    }

    return self;
}

/**
 * Restart Chat HTML template content and see if we need to show an initial message
 */
- (void)awakeFromNib
{
    AppDelegate *delegate = [NSApp delegate];
    [[self window] setBackgroundColor:[[delegate styleManager] backgroundColor]];
    [[webView mainFrame] loadHTMLString:[[delegate styleManager] indexTemplate]
                                baseURL:nil];

    if (firstMessage)
    {
        [self xmppStream:xmppStream didReceiveMessage:firstMessage];
        firstMessage  = nil;
    }
}

/**
 * Called immediately before the window closes.
 * 
 * This method's job is to release the WindowController (self)
 * This is so that the nib file is released from memory.
 **/
- (void)windowWillClose:(NSNotification *)aNotification
{
    DDLogVerbose(@"ChatController: windowWillClose");
    
    [xmppStream removeDelegate:self];
    [WindowManager closeChatWindow:self];
}

- (void)scrollToBottom
{
    [webView stringByEvaluatingJavaScriptFromString:@"scrollIfNeeded();"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Chat Messages HTML crafting
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addMessage:(XMPPMessage *)message
{
    if (!webViewIsReady)
    {
        [self performSelector:@selector(addMessage:)
				   withObject:message
				   afterDelay:0];
        return;
    }

    AppDelegate *delegate = [NSApp delegate];
    [[delegate styleManager] addMessageToView:webView message:message];
    [self scrollToBottom];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Webview delegates
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Invoked once the webview has loaded and is ready to accept content
 */
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    webViewIsReady = YES;
}

/*
 * Prevent the webview from following external links.  We direct these to the user's web browser.
 */
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
		  frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSInteger actionKey = [[actionInformation objectForKey:WebActionNavigationTypeKey] integerValue];

    if (actionKey == WebNavigationTypeOther)
		[listener use];
    else
        [listener ignore];
}

/*
 * Append our own menu items to the webview's contextual menus
 */
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element 
	defaultMenuItems:(NSArray *)defaultMenuItems
{
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPP Events
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [messageField setEnabled:YES];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if (![jid isEqual:[message from]]) return;
    
    if([message isChatMessageWithBody])
    {
        [self addMessage:message];
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    [messageField setEnabled:NO];
}

- (IBAction)sendMessage:(id)sender
{
    NSString *messageStr = [messageField stringValue];
    
    if([messageStr length] > 0)
    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:[jid full]];
        [message addAttributeWithName:@"from" stringValue:[[xmppStream myJID] full]];
        [message addChild:body];
        
        [xmppStream sendElement:message];
        [self addMessage:[XMPPMessage messageFromElement:message]];

        [messageField setStringValue:@""];
        [[self window] makeFirstResponder:messageField];
    }
}

@end
