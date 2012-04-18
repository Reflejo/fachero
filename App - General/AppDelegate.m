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

#import "AppDelegate.h"
#import "RosterController.h"
#import "LoginController.h"
#import "CustomWindow.h"
#import "StyleManager.h"

#import <WebKit/WebKit.h>

@implementation AppDelegate

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppvCardAvatarModule;
@synthesize xmppPing;
@synthesize styleManager;

- (id)init
{
    if ((self = [super init]))
    {
        styleManager = [[StyleManager alloc] initWithName:@"minimal_mod"];

        // Configure logging framework
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        // Initialize variables
        xmppStream = [[XMPPStream alloc] init];
        xmppReconnect = [[XMPPReconnect alloc] init];
        
        xmppRosterStorage = [[XMPPRosterMemoryStorage alloc] init];
        xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
        
        //    xmppCapabilitiesStorage = [[XMPPCapabilitiesCoreDataStorage alloc] init];
        //    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
        
        xmppPing = [[XMPPAutoPing alloc] init];
        //    xmppTime = [[XMPPTime alloc] init];
        
        // Setup vCard support
        // 
        // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
        // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
        xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
        xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
        
        turnSockets = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [window setBarWithInitColor:kMainWindowGradientInit 
                       endColor:kMainWindowGradientEnd];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [WebView registerURLSchemeAsLocal:@"facechat"];   
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Activate xmpp modules
    [xmppReconnect activate:xmppStream];
    [xmppRoster activate:xmppStream];
    [xmppCapabilities activate:xmppStream];
    [xmppPing activate:xmppStream];
    [xmppTime activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    xmppReconnect.autoReconnect = YES;
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    //    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardAvatarModule addDelegate:rosterController delegateQueue:dispatch_get_main_queue()];
    [xmppvCardTempModule addDelegate:rosterController delegateQueue:dispatch_get_main_queue()];
    [xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppTime addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Start the GUI stuff
    [loginController displaySignIn];
}

- (BOOL)windowShouldClose:(id)sender 
{
    [[NSApplication sharedApplication] hide:self];
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Auto Reconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    DDLogVerbose(@"---------- xmppReconnect:shouldAttemptAutoReconnect: ----------");
    return YES;
}


- (void)xmppPing:(XMPPPing *)sender didReceivePong:(XMPPIQ *)pong withRTT:(NSTimeInterval)rtt
{
	NSLog(@"ASDASIJDSAJ_----AD_SA _SA D_AS D_AS D_SA");
}

- (void)xmppPing:(XMPPPing *)sender didNotReceivePong:(NSString *)pingID dueToTimeout:(NSTimeInterval)timeout
{
	NSLog(@"ASDASIJDSAJ_----AD_SA _SA D_AS D_AS D_SA--------------2");
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
    NSLog(@"ASDASIJDSAJ_----AD_SA _SA D_AS D_AS D_SA--------------3");
}

@end
