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
#import "SSKeychain.h"
#import "CustomWindow.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <QuartzCore/CoreAnimation.h>


@implementation RosterController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Setup:
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Sign In Sheet
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)displaySignInSheet
{
    NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];
    
    [jidField setObjectValue:[dflts objectForKey:@"Account.JID"]];
    [rememberPasswordCheckbox setObjectValue:[dflts objectForKey:@"Account.RememberPassword"]];
    
    if ([rememberPasswordCheckbox state] == NSOnState)
    {
        NSString *jidStr = [[jidField stringValue] lowercaseString];
        
        NSString *password = [SSKeychain passwordForService:@"XMPPFramework" account:jidStr];
        if (password)
            [passwordField setStringValue:password];
        
        // If user was prompted for keychain permission, we may need to restore
        // focus to our application
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void)enableSignInUI:(BOOL)enabled
{
    [jidField setEnabled:enabled];
    [passwordField setEnabled:enabled];
    [rememberPasswordCheckbox setEnabled:enabled];
    
    [signInButton setEnabled:enabled];
}

- (void)updateAccountInfo
{
    [[self xmppStream] setHostName:kServerDomain];
    [[self xmppStream] setHostPort:kServerPort];
    
    NSString *resource = (__bridge_transfer NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);
    
    NSString *jUser = [NSString stringWithFormat:@"%@@chat.facebook.com", [jidField stringValue]];
    XMPPJID *jid = [XMPPJID jidWithString:jUser resource:resource];
    
    [[self xmppStream] setMyJID:jid];
    
    // Update persistent info
    NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];
    [dflts setObject:[jidField stringValue]
              forKey:@"Account.JID"];

    if ([rememberPasswordCheckbox state] == NSOnState)
    {
        NSString *jidStr   = [jidField stringValue];
        NSString *password = [passwordField stringValue];
        
        [SSKeychain setPassword:password forService:@"XMPPFramework" account:jidStr];
        
        [dflts setBool:YES forKey:@"Account.RememberPassword"];
    }
    else
    {
        [dflts setBool:NO forKey:@"Account.RememberPassword"];
    }
    
    [dflts synchronize];
}

- (IBAction)signIn:(id)sender
{
    [self updateAccountInfo];
    
    NSError *error = nil;
    BOOL success;
    
    if(![[self xmppStream] isConnected])
    {
        success = [[self xmppStream] connect:&error];
    }
    else
    {
        NSString *password = [passwordField stringValue];
        success = [[self xmppStream] authenticateWithPassword:password error:&error];
    }
    
    if (success)
    {
        isAuthenticating = YES;
        [self enableSignInUI:NO];
    }
    else
    {
        [messageField setStringValue:[error localizedDescription]];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Presence Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)goOnline
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"type" stringValue:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

- (IBAction)changePresence:(id)sender
{
    if([[sender titleOfSelectedItem] isEqualToString:@"Offline"])
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
        [avatar setPicture:user.photo];
    }
    else
    {
        AppDelegate *delegate = [NSApp delegate];
        
        NSData *photoData = [[delegate xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            [avatar setAvatar:[[NSImage alloc] initWithData:photoData]];
    }
    
    if (user.isOnline) [avatar setOnline];
    else [avatar setOffline];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark IBActions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)chat:(id)sender
{
    int selectedRow = [rosterTable clickedRow];
    if (selectedRow >= 0)
    {
        XMPPStream *stream = [self xmppStream];
        id <XMPPUser> user = [roster objectAtIndex:selectedRow];
        
        [WindowManager openChatWindowWithStream:stream forUser:user];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Roster Table Data Source
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    ItemTableCellView *view = [aTableView makeViewWithIdentifier:@"ItemCell" owner:self];
    [view setUser:[roster objectAtIndex:row]];
    [self configurePhotoForAvatar:view->avatar user:[roster objectAtIndex:row]];
    [view setIsSelected:NO];
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Window animations
/////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
    int index;
    for (index = 0; index < kNumberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, 
                             NSMinX(frame) - frame.size.width * kVigourOfShake, 
                             NSMinY(frame));
        CGPathAddLineToPoint(shakePath, NULL, 
                             NSMinX(frame) + frame.size.width * kVigourOfShake,
                             NSMinY(frame));
    }
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = kDurationOfShake;
    return shakeAnimation;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPClient Delegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);    
    [settings setObject:[sender hostName] forKey:(NSString *)kCFStreamSSLPeerName];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isOpen = YES;
    
    NSString *password = [passwordField stringValue];
    
    NSError *error = nil;
    BOOL success = [[self xmppStream] authenticateWithPassword:password error:&error];
    
    if (!success)
        [messageField setStringValue:[error localizedDescription]];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Update tracking variables
    isAuthenticating = NO;
    
    // Close the sheet
    [tabs selectNextTabViewItem:nil];
    [(CustomWindow *)window setToolbarHidden:NO];
    
    // Send presence
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Shake window!
    NSRect rect = [window frame];
    [window setAnimations:[NSDictionary dictionaryWithObject:[self shakeAnimation:rect] 
                                                      forKey:@"frameOrigin"]];
    [[window animator] setFrameOrigin:rect.origin];

    // Update tracking variables
    isAuthenticating = NO;
    
    // Update GUI
    [self enableSignInUI:YES];
    [messageField setStringValue:@"Invalid username/password"];
}

- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!roster)
    {
        NSString *user = [[[sender myUser] displayName] 
                          stringByReplacingOccurrencesOfString:@"@chat.facebook.com"
                          withString:@""];

        [self configurePhotoForAvatar:userAvatar user:[sender myUser]];
        [userName setStringValue:[user capitalizedString]];
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
    
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isOpen)
        [messageField setStringValue:@"Cannot connect to server"];
    
    // Update tracking variables
    isOpen = NO;
    isAuthenticating = NO;
    
    // Update GUI
    [self enableSignInUI:YES];
}

@end
