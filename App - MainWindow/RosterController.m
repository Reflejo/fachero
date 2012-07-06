/*
 * Author: Mart’n Conte Mac Donell <Reflejo@gmail.com>
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

#import "RosterController.h"
#import "WindowManager.h"
#import "AppDelegate.h"


@implementation RosterController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Setup:
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPStream *)xmppStream
{
    return [[NSApp delegate] xmppStream];
}

- (XMPPRoster *)xmppRoster
{
    return [[NSApp delegate] xmppRoster];
}

- (XMPPRosterMemoryStorage *)xmppRosterStorage
{
    return [[NSApp delegate] xmppRosterStorage];
}

- (void)awakeFromNib
{
    DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[self xmppRoster] setAutoFetchRoster:YES];
    [[self xmppRoster] setAutoAcceptKnownPresenceSubscriptionRequests:YES];
    
    [[self xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self xmppRoster] addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [rosterTable setTarget:self];
    [rosterTable setDoubleAction:@selector(chat:)];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Presence Management
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)goOnline
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];

    [[self xmppStream] sendElement:presence];
    [rosterTable reloadData];
    
    [statusButtonItem setImage:[NSImage imageNamed:@"onlineIndicator"]];
}

- (void)goOffline
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"type" stringValue:@"invisible"];
    
    [[self xmppStream] sendElement:presence];
    [statusButtonItem setImage:[NSImage imageNamed:@"offlineIndicator"]];
}

- (IBAction)changePresence:(id)sender
{
    if ([[sender titleOfSelectedItem] isEqualToString:@"Invisible"])
    {
        [self goOffline];
    }
    else
    {
        [self goOnline];
    }
}

/**
 * Check if user photo is in cache, download otherwise and show into avatar field
 */
- (void)configurePhotoForAvatar:(RoundedAvatar *)avatar user:(XMPPUserMemoryStorageObject *)user                                                                                                   
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    if (user.photo != nil)
    {
        [avatar setAvatar:user.photo];
    }
    else
    {
        AppDelegate *delegate = [NSApp delegate];
        
        NSData *photoData = [[delegate xmppvCardAvatarModule] photoDataForJID:user.jid];
        if (photoData != nil)
            [avatar setAvatar:[[NSImage alloc] initWithData:photoData]];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark IBActions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)chat:(id)sender
{
    int selectedRow = [rosterTable clickedRow];
    selectedRow = (selectedRow < 0) ? [rosterTable selectedRow]: selectedRow;
    if (selectedRow >= 0)
    {
        XMPPStream *stream = [self xmppStream];
        id <XMPPUser> user = [roster objectAtIndex:selectedRow];
        
        [WindowManager openChatWindowWithStream:stream forUser:user];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Roster Table Data Source
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [roster count];
}

/**
 * This selector is called when a user select some option. This is implemented in order
 * to change text color on item highlighting. Is there any other way?.
 *
 * We'll keep track of the last selected cell in order to reset styles when other is selected.
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    ItemTableCellView *view;
    
    if (lastSelected)
        [lastSelected setIsSelected:NO];
    
    if (rowIndex >= 0)
    {
        view = [aTableView viewAtColumn:0 row:rowIndex makeIfNecessary:NO];
        lastSelected = view;
        [view setIsSelected:YES];
    }
    
    return YES;
}

/**
 * This delegate function will change the TableRow to our custom made 
 * ItemTableRowView, where we can customize row selection and backgrounds.
 */
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    ItemTableRowView *result = [[ItemTableRowView alloc] init];
    return result;
}

/**
 * This delegate function will return the rowView that we'll add into
 * tableView. Name and photo is setted here.
 */
- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)tableColumn 
                  row:(NSInteger)row
{
    XMPPUserMemoryStorageObject *user = [roster objectAtIndex:row];
    ItemTableCellView *view = [aTableView makeViewWithIdentifier:@"ItemCell" owner:self];
    [view setUser:[roster objectAtIndex:row]];
    [view->avatar defaultAvatar];
    
    [self configurePhotoForAvatar:view->avatar user:user];
    
    // Change status indicator
    if (user.isOnline) [view setOnline];
    else [view setOffline];
    
    return view;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPClient Delegate Methods
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // Send presence
    [self goOnline];
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule 
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp 
                     forJID:(XMPPJID *)jid
{
    ItemTableCellView *view;
    for (int i = 0; i < [rosterTable numberOfRows]; i++)
    {
        view = [rosterTable viewAtColumn:0 row:i makeIfNecessary:NO];
        if (!view) continue;

        if ([jid isEqualToJID:[view->user jid]])
        {
            [self configurePhotoForAvatar:view->avatar user:[roster objectAtIndex:i]];
            break;
        }
    }
}

- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if ([[userName stringValue] isEqualToString:@""])
    {
        NSString *user = [[[sender myUser] displayName] 
                          stringByReplacingOccurrencesOfString:@"@chat.facebook.com"
                          withString:@""];

        if (user)
        {
            [userAvatar setStrokeColor:[NSColor blackColor]];
            [userName setStringValue:[user capitalizedString]];
            [self configurePhotoForAvatar:userAvatar user:[sender myUser]];
        }
    }
    roster = [sender sortedUsersByAvailabilityName];
    
    [rosterTable abortEditing];
    [rosterTable selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    [rosterTable reloadData];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if ([message isChatMessageWithBody])
        [WindowManager handleMessage:message withStream:sender];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

@end
