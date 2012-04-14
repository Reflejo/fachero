//
//  ItemTableCellView.h
//  Penteskine
//
//  Created by Martin Conte Mac Donell on 10/17/11.
//  Copyright 2011 kodear. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "RoundedAvatar.h"
#import "XMPPUser.h"

@interface ItemTableCellView : NSTableCellView {
    id <XMPPUser> user;
    IBOutlet NSTextField *name;
    
@public
    IBOutlet RoundedAvatar *avatar;
    BOOL isSelected;
}

- (void)setIsSelected:(BOOL)isSelected;

-(void)setUser:(id <XMPPUser>) user;
//@property (nonatomic) id <XMPPUser> user;

@end
