//
//  ContactListTableView.m
//  Fachero
//
//  Created by Usuario Vacio on 5/17/12.
//  Copyright (c) 2012 kodear. All rights reserved.
//

#import "ContactListTableView.h"

@implementation ContactListTableView

-(void)keyDown:(NSEvent *)theEvent
{
    if (([theEvent keyCode] == 49) || ([theEvent keyCode] == 36))
    {
        [self.delegate performSelector:[self doubleAction] withObject:nil];
    }

    [super keyDown:theEvent];
}

@end
