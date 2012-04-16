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
#import "MessageTableCellView.h"
#import "XMPPRosterMemoryStorage.h"
#import "AppDelegate.h"

@interface ChatController (PrivateAPI)
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ChatController

@synthesize xmppStream;
@synthesize jid;

- (XMPPRosterMemoryStorage *)storage
{
    return [[NSApp delegate] xmppRosterStorage];
}

- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid
{
    return [self initWithStream:stream jid:aJid message:nil];
}

- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid message:(XMPPMessage *)message
{
    if ((self = [super initWithWindowNibName:@"ChatWindow"]))
    {
        messages = [NSMutableArray array];
        xmppStream = stream;
        jid = aJid;
        
        firstMessage = message;
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [[self window] setTitle:[[self storage] userForJID:aJid].nickname];
        [[self window] makeFirstResponder:messageField];
        [[[self window] standardWindowButton:NSWindowMiniaturizeButton]setHidden:YES];
        [[[self window] standardWindowButton:NSWindowZoomButton] setHidden:YES];
        [[self window] setBackgroundColor:NSColorFromRGB(0xf6f6fa)];
    }
    return self;
}

- (void)awakeFromNib
{
    [[webView mainFrame] loadHTMLString:@"<html><body>oasdjiasj||||||||ASodASKDOSdiasjdiasd</body></html>" 
                                baseURL:[NSURL URLWithString:@"http://127.0.0.1/"]];

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
    NSPoint newScrollOrigin;
    
    if ([[scrollView documentView] isFlipped])
        newScrollOrigin = NSMakePoint(0.0F, NSMaxY([[scrollView documentView] frame]));
    else
        newScrollOrigin = NSMakePoint(0.0F, 0.0F);
    
    [[scrollView documentView] scrollPoint:newScrollOrigin];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Roster Table Data Source
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [messages count];
}

/**
 * This selector is called when a user select some option. Do not allow selections.
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return NO;
}

/**
 * This delegate function will return the rowView that we'll add into
 * tableView. Name and photo is setted here.
 */
- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)tableColumn 
                  row:(NSInteger)row
{
    MessageTableCellView *view;
    XMPPMessage *message = [messages objectAtIndex:row];
    NSString *messageStr = [[message elementForName:@"body"] stringValue];
    AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
    XMPPJID *myJID = [[delegate xmppStream] myJID];
    XMPPJID *userJID = [message from] ? [message from]: myJID;
    NSData *photoData = [[delegate xmppvCardAvatarModule] photoDataForJID:userJID];

    if ([userJID isEqualToJID:myJID])
    {
        view = [aTableView makeViewWithIdentifier:@"messageFrom" owner:self];
        [[view bubbleView] setStyle:kBubbleFrom];
    }
    else
    {
        view = [aTableView makeViewWithIdentifier:@"messageTo" owner:self];
        [[view bubbleView] setStyle:kBubbleTo];
    }

    [[view avatar] setAvatar:[[NSImage alloc] initWithData:photoData]];
    [[view bubbleView] setString:messageStr];
    return view;
}

/**
 * Do not allow editing.
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn 
              row:(NSInteger)rowIndex
{
    return NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPP Events
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [messageField setEnabled:YES];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if(![jid isEqual:[message from]]) return;
    NSLog(@"ASDOASDKASO JID!!!!!!!!!!!!!!!!!! %@", [message from]);
    
    if([message isChatMessageWithBody])
    {
        /*NSString *messageStr = [[message elementForName:@"body"] stringValue];
        
        NSString *paragraph = [NSString stringWithFormat:@"%@\n\n", messageStr];
        
        NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
        [mps setAlignment:NSLeftTextAlignment];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
        [attributes setObject:mps forKey:NSParagraphStyleAttributeName];
        [attributes setObject:[NSColor colorWithCalibratedRed:250 green:250 blue:250 alpha:1] forKey:NSBackgroundColorAttributeName];
        
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
        
        [[messageView textStorage] appendAttributedString:as];*/
        [messages addObject:message];
        [tableView reloadData];
        [self scrollToBottom];
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
        /*
        NSString *paragraph = [NSString stringWithFormat:@"%@\n\n", messageStr];
        
        NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
        [mps setAlignment:NSRightTextAlignment];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
        [attributes setObject:mps forKey:NSParagraphStyleAttributeName];
        
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
        
        [[messageView textStorage] appendAttributedString:as];*/
        [messages addObject:[XMPPMessage messageFromElement:message]];

        [tableView reloadData];

        [messageField setStringValue:@""];
        [[self window] makeFirstResponder:messageField];
        [self scrollToBottom];
    }
}

@end
