//
//  RoundedAvatar.h
//  XMPPStream
//
//  Created by Usuario Vacio on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RoundedAvatar : NSView
{
    NSImage *picture;
    IBOutlet NSImageView *statusIndicator;
}

@property (nonatomic) NSImage *picture;

-(void)setOnline;
-(void)setOffline;

@end
