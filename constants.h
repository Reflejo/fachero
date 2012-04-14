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

#ifndef FacebookChat_constants_h
#define FacebookChat_constants_h

#import "DDLog.h"
#import "DDTTYLogger.h"

// Custom Functions
#define NSColorFromRGB(rgbValue) [NSColor \
    colorWithCalibratedRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                     green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                      blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define kMainWindowGradientInit     NSColorFromRGB(0x385f96)
#define kMainWindowGradientEnd      NSColorFromRGB(0x2f5288)


#define kServerDomain	@"chat.facebook.com"
#define kServerPort		5222

#endif
