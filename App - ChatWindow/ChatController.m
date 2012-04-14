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

#import "ChatController.h"
#import "WindowManager.h"
#import "XMPPFramework.h"

@interface ChatController (PrivateAPI)
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ChatController

@synthesize xmppStream;
@synthesize jid;

- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid
{
	return [self initWithStream:stream jid:aJid message:nil];
}

- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid message:(XMPPMessage *)message
{
	if ((self = [super initWithWindowNibName:@"ChatWindow"]))
	{
		xmppStream = stream;
		jid = aJid;
		
		firstMessage = message;
	}
	return self;
}

- (void)awakeFromNib
{
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[messageView setString:@""];
	
	[[self window] setTitle:[jid full]];
	[[self window] makeFirstResponder:messageField];
	
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
	NSScrollView *scrollView = [messageView enclosingScrollView];
	NSPoint newScrollOrigin;
	
	if ([[scrollView documentView] isFlipped])
		newScrollOrigin = NSMakePoint(0.0F, NSMaxY([[scrollView documentView] frame]));
	else
		newScrollOrigin = NSMakePoint(0.0F, 0.0F);
	
	[[scrollView documentView] scrollPoint:newScrollOrigin];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	[messageField setEnabled:YES];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	if(![jid isEqual:[message from]]) return;
	
	if([message isChatMessageWithBody])
	{
		NSString *messageStr = [[message elementForName:@"body"] stringValue];
		
		NSString *paragraph = [NSString stringWithFormat:@"%@\n\n", messageStr];
		
		NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
		[mps setAlignment:NSLeftTextAlignment];
		
		NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
		[attributes setObject:mps forKey:NSParagraphStyleAttributeName];
		[attributes setObject:[NSColor colorWithCalibratedRed:250 green:250 blue:250 alpha:1] forKey:NSBackgroundColorAttributeName];
		
		NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
		
		[[messageView textStorage] appendAttributedString:as];
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
		[message addChild:body];
		
		[xmppStream sendElement:message];
		
		NSString *paragraph = [NSString stringWithFormat:@"%@\n\n", messageStr];
		
		NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
		[mps setAlignment:NSRightTextAlignment];
		
		NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
		[attributes setObject:mps forKey:NSParagraphStyleAttributeName];
		
		NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
		
		[[messageView textStorage] appendAttributedString:as];
		
		[self scrollToBottom];
		
		[messageField setStringValue:@""];
		[[self window] makeFirstResponder:messageField];
	}
}

@end
