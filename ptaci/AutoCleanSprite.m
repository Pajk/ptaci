//
//  AutoCleanSprite.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AutoCleanSprite.h"

@implementation AutoCleanSprite

- (void)removeFromParent {
    CCNode *parent = self.parent;
    [self retain];
    [parent removeChild:self cleanup:YES];
    [self autorelease];
}

@end
