//
//  MainMenuScene.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameState.h"
#import "AppDelegate.h"

@implementation MainMenuScene
@synthesize layer = _layer;

- (id)init {
    if ((self = [super init])) {
        self.layer = [[[MainMenuLayer alloc] init] autorelease];
        [self addChild:_layer];
    }
    return self;
}

@end

@implementation MainMenuLayer
@synthesize batchNode = _batchNode;
@synthesize main_bkgrnd = _main_bkgrnd;

- (id)init {
    
    if ((self = [super init])) {
        
        // Add a sprite sheet based on the loaded texture and add it to the scene
        self.batchNode = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        [self addChild:_batchNode];
        
        // Add main background to scene
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.main_bkgrnd = [CCSprite spriteWithSpriteFrameName:@"Menu_background.png"];
        _main_bkgrnd.position = ccp(winSize.width/2, winSize.height/2);
        [_batchNode addChild:_main_bkgrnd];
        
        // Add new game button
        CCSprite *newGameSprite = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        CCMenuItem *newGameItem = [CCMenuItemSprite itemFromNormalSprite:newGameSprite selectedSprite:nil target:self selector:@selector(newGameSpriteTapped:)];
        CCMenu *menu = [CCMenu menuWithItems:newGameItem, nil];
        [self addChild:menu];
        
    }
    
    return self;
}

- (void)newGameSpriteTapped:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate launchNewGame];
}

@end

