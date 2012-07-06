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

#import "StyleManager.h"
#import "XMPPMessage.h"
#import "XMPPJID.h"
#import "AppDelegate.h"

#import <WebKit/WebKit.h>

#define kBundleContents             @"Contents"
#define kBundleResources            @"Resources"
#define kMessageStyleDirectory      @"Message Styles"
#define kBundleExtension            @".FaceChatMessageStyle"

#define kHTMLIndexFile              @"window.html"
#define kHTMLMessageFile            @"message.html"
#define kHTMLDemoName               @"mockup.html"

#define kImageFormat                @"facechat://%@/facechat.jpeg"

@implementation StyleManager

@synthesize indexTemplate;

/**
 * Load bundle according to given theme name and preload templates 
 * and needed resources once.
 */
-(id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        // Load bundle file according to given name
        NSString *bundleName = [NSString stringWithFormat:@"%@%@", name, kBundleExtension];
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSArray *relPath = [NSArray arrayWithObjects:kBundleContents, kBundleResources,
                            kMessageStyleDirectory, bundleName, nil];
        NSString *fullPath = [bundlePath stringByAppendingPathComponent:
                              [NSString pathWithComponents:relPath]];
        
        bundle = [NSBundle bundleWithPath:fullPath];

        dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"HH:mm"];

        // Preload Templates
        messageTemplate = [self loadTemplate:kHTMLMessageFile];
        indexTemplate = [self loadTemplate:kHTMLIndexFile];
    }

    return self;
}

/**
 * Get the backgroundColor property from bundle if exists,
 * return the default color otherwise.
 */
-(NSColor *)backgroundColor
{
    int color = [[bundle objectForInfoDictionaryKey:@"BackgroundColor"] intValue];
    return (color >= 0) ? NSColorFromRGB(color): kChatWindowBackground;
}

/**
 * Load HTML templates from theme, there is two parts templates:
 *
 * 1) main layout: Is the basic layout, the only thing replaced is "bodyHREF"
 *    which gets the full path of the resources.
 *
 * 2) message: Is the templated that is appened for each message. 
 */
-(NSString *)loadTemplate:(NSString *)type
{
    // Prepare paths to read HTML templates
    NSString *messagePath = [[bundle resourcePath] stringByAppendingPathComponent:type];
    
    NSString *tpl = [NSString stringWithContentsOfFile:messagePath
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];

    NSString *urlPath = [[NSURL fileURLWithPath:[bundle resourcePath]] absoluteString];
    return [tpl stringByReplacingOccurrencesOfString:@"%bodyHREF%" 
                                          withString:urlPath];
}

/**
 * Add message HTML template (crafted by the XMPPMessage) to
 * given WebView. Also replace variables:
 *    %time%. %sender%, %userIconPath, %message%, %time%
 */
-(void)addMessageToView:(WebView *)view message:(XMPPMessage *)message
{
    NSString *messageStr = [[message elementForName:@"body"] stringValue];
    AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
    XMPPJID *myJID = [[delegate xmppStream] myJID];
    XMPPJID *fromJID = [message from];
    
    // Sanitize string. Strip HTML tags and some other fixes
    messageStr = [StyleManager stringByStrippingHTMLFrom:messageStr];

    // Get data from storage. It should be there. Then add into WebResources
    // if it isn't there.
    NSData *photoData = [[delegate xmppvCardAvatarModule] photoDataForJID:fromJID];
    NSString *imageSRC = [NSString stringWithFormat:kImageFormat, [fromJID user]];
    WebResource	*res = [[[view mainFrame] dataSource] 
                        subresourceForURL:[NSURL URLWithString:imageSRC]];
    if (!res)
    {
        res = [[WebResource alloc] initWithData:photoData
                                            URL:[NSURL URLWithString:imageSRC]
                                       MIMEType:@"image/jpeg" 
                               textEncodingName:nil  
                                      frameName:nil];   
        [[[view mainFrame] dataSource] addSubresource:res];
    }

    // Replace needed variables into message HTML template
    NSMutableString *tpl = [messageTemplate mutableCopy];
    [tpl replaceOccurrencesOfString:@"%userIconPath%"
                         withString:imageSRC
                            options:0
                              range:NSMakeRange(0, [tpl length])];

    [tpl replaceOccurrencesOfString:@"%messageClasses%"
                         withString:[myJID isEqualToJID:fromJID] ? @"message-from": @"message-to"
                            options:0
                              range:NSMakeRange(0, [tpl length])];
    
    [tpl replaceOccurrencesOfString:@"%message%"
                         withString:messageStr
                            options:0
                              range:NSMakeRange(0, [tpl length])];

    [tpl replaceOccurrencesOfString:@"%sender%"
                         withString:[[delegate xmppRosterStorage] userForJID:fromJID].displayName
                            options:0
                              range:NSMakeRange(0, [tpl length])];

    [tpl replaceOccurrencesOfString:@"%time%"
                         withString:[dateFormater stringFromDate:[NSDate date]]
                            options:0
                              range:NSMakeRange(0, [tpl length])];

    // Finally, create DOM elements and add those into the view
    DOMHTMLDivElement *container = (DOMHTMLDivElement *)[[[view mainFrame] DOMDocument] 
                                                         getElementById:@"chat-window"];
	DOMHTMLDivElement *div = (DOMHTMLDivElement *)[[[view mainFrame] DOMDocument] createElement:@"div"];
    [div setInnerHTML:tpl];
    
    [container appendChild:div];
}

+ (NSString *)stringByStrippingHTMLFrom:(NSString *)html
{
    NSMutableString *s = [html mutableCopy];
    [s replaceOccurrencesOfString:@"<"
                       withString:@"&lt;"
                          options:0
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@">"
                       withString:@"&gt;"
                          options:0
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n"
                       withString:@"<br/>"
                          options:0
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"  "
                       withString:@"&nbsp; "
                          options:0
                            range:NSMakeRange(0, [s length])];
    
    return s; 
}


@end