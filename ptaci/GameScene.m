//
//  HelloWorldLayer.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "GameScene.h"

@implementation GameScene

@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        // add hud layer
        HUDLayer *hud = [HUDLayer node];
        [self addChild:hud z:1];
        // add action layer (with cocos and bear:)
        self.layer = [[[ActionLayer alloc] initWithHUD:hud] autorelease];
        [self addChild:_layer];
    }	
	return self;
}

- (void)dealloc {
    self.layer = nil;
    [super dealloc];
}

@end