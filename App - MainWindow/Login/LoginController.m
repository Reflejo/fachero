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

#import "LoginController.h"
#import "SSKeychain.h"
#import "AppDelegate.h"
#import "AnimationFlipWindow.h"
#import "NSView+Fade.h"

#import <QuartzCore/CoreAnimation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation LoginController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Setup:
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPStream *)xmppStream
{
    return [[NSApp delegate] xmppStream];
}

- (void)awakeFromNib
{
    [[self xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    DDLogVerbose(@"LoginController: windowWillClose");
    [[self xmppStream] removeDelegate:self];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Sign In Sheet
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)displaySignIn
{
    NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];
    
    [jidField setObjectValue:[dflts objectForKey:@"Account.JID"]];
    [rememberPasswordCheckbox setObjectValue:[dflts objectForKey:@"Account.RememberPassword"]];
    
    if ([rememberPasswordCheckbox state] == NSOnState)
    {
        NSString *jidStr = [[jidField stringValue] lowercaseString];
        
        NSString *password = [SSKeychain passwordForService:@"FacebookChat" account:jidStr];
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
        
        [SSKeychain setPassword:password forService:@"FacebookChat" account:jidStr];
        
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
	[loginForm setHidden:YES withFade:YES];
	[loadingIndicator setHidden:NO];
	
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
        [self shakeWindow];
    }
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

/*
 * Shake window! (Normaly used to denote errors or login failures)
 */
- (void)shakeWindow
{
	NSRect rect = [window frame];
	[window setAnimations:[NSDictionary dictionaryWithObject:[self shakeAnimation:rect] 
													  forKey:@"frameOrigin"]];
	[[window animator] setFrameOrigin:rect.origin];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPClient Delegate Methods
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
		[self shakeWindow];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // Update tracking variables
    isAuthenticating = NO;
    
    // Close the sheet
    if (![contactsWindow isVisible])
    {
        AnimationFlipWindow *flip = [[AnimationFlipWindow alloc] init];
        [flip flip:window toBack:contactsWindow];
    }
    
    // Send presence
//    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	[self shakeWindow];
    
    // Update tracking variables
    isAuthenticating = NO;
    
    // Update GUI
    [self enableSignInUI:YES];
}


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isOpen)
        [self shakeWindow];
    
    // Update tracking variables
    isOpen = NO;
    isAuthenticating = NO;
    
    // Update GUI
    [self enableSignInUI:YES];
}

@end
