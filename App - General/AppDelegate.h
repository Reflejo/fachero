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

#import "CustomWindow.h"
#import "XMPPFramework.h"

@class RosterController;

@interface AppDelegate : NSObject
{
    __strong XMPPStream *xmppStream;
    __strong XMPPReconnect *xmppReconnect;
    __strong XMPPRoster *xmppRoster;
    __strong XMPPRosterMemoryStorage *xmppRosterStorage;
    __strong XMPPCapabilities *xmppCapabilities;
    __strong XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    __strong XMPPPing *xmppPing;
    __strong XMPPTime *xmppTime;
    
    __strong XMPPvCardCoreDataStorage *xmppvCardStorage;
    __strong XMPPvCardTempModule *xmppvCardTempModule;
    __strong XMPPvCardAvatarModule *xmppvCardAvatarModule;
    
    NSMutableArray *turnSockets;
    
    IBOutlet RosterController *rosterController;
    
    IBOutlet CustomWindow *window;
}

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, readonly) XMPPRosterMemoryStorage *xmppRosterStorage;
@property (nonatomic, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, readonly) XMPPPing *xmppPing;


@end
