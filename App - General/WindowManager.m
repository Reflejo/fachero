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

#import "WindowManager.h"
#import "ChatController.h"

@implementation WindowManager

static NSMutableArray *chatControllers;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{        
        chatControllers = [[NSMutableArray alloc] init];
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ChatController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (ChatController *)chatControllerForJID:(XMPPJID *)jid matchResource:(BOOL)matchResource
{
    // Loop through all the open chat windows, and see if any of them are the one we want...
    XMPPJIDCompareOptions options = matchResource ? XMPPJIDCompareFull : XMPPJIDCompareBare;
    
    for (ChatController *chatController in chatControllers)
    {
        XMPPJID *currentJID = [chatController jid];
        
        if ([currentJID isEqualToJID:jid options:options])
            return chatController;
    }
    
    return nil;
}

+ (void)openChatWindowWithStream:(XMPPStream *)xmppStream forUser:(id <XMPPUser>)user
{
    ChatController *chatController = [self chatControllerForJID:[user jid] matchResource:NO];
    
    if (chatController)
    {
        [[chatController window] makeKeyAndOrderFront:self];
    }
    else
    {
        // Create chat controller
        XMPPJID *jid;
        
        id <XMPPResource> primaryResource = [user primaryResource];
        if (primaryResource)
            jid = [primaryResource jid];
        else
            jid = [user jid];
        
        chatController = [[ChatController alloc] initWithStream:xmppStream jid:jid];
        [chatController showWindow:self];
        
        [chatControllers addObject:chatController];
    }
}

+ (void)closeChatWindow:(ChatController *)chatController
{
    [chatControllers removeObject:chatController];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark HandleMessage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)handleMessage:(XMPPMessage *)message withStream:(XMPPStream *)xmppStream
{
    ChatController *chatController = [self chatControllerForJID:[message from] matchResource:YES];
    
    if (chatController == nil)
    {
        // Create new chat window
        XMPPJID *jid = [message from];
        NSLog(@"%@ -------------------", [[message from] user]);
        
        chatController = [[ChatController alloc] initWithStream:xmppStream jid:jid message:message];
        [chatController showWindow:self];
        
        [chatControllers addObject:chatController];
    }
}

@end
